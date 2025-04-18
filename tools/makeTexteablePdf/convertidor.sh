#!/bin/bash

# Verificación de dependencias
missing=()

command -v tesseract >/dev/null 2>&1 || missing+=("tesseract")
command -v magick >/dev/null 2>&1 || missing+=("imagemagick (magick)")
command -v pdfunite >/dev/null 2>&1 || missing+=("pdfunite (poppler)")
command -v gs >/dev/null 2>&1 || missing+=("ghostscript")

if [ ${#missing[@]} -ne 0 ]; then
    echo "❌ Faltan las siguientes dependencias:"
    for m in "${missing[@]}"; do echo " - $m"; done
    echo "Puedes instalarlas con:"
    echo "  sudo pacman -S tesseract imagemagick poppler ghostscript"
    exit 1
fi

# Verifica argumento de entrada
if [ -z "$1" ]; then
    echo "Uso: $0 archivo.pdf|directorio [idioma] [resolución]"
    echo "Ejemplos:"
    echo "  $0 documento.pdf spa 150"
    echo "  $0 documento.pdf 150     (usa inglés por defecto)"
    echo "  $0 directorio_imagenes/ spa 150"
    echo "Resolución predeterminada: 150 dpi (menor valor = menor tamaño, calidad recomendada: 150-300)"
    exit 1
fi

input_path="$1"
lang="eng" # por defecto inglés
resolution="150" # resolución predeterminada 150 dpi

# Comprobar si hay segundo parámetro y determinar si es idioma o resolución
if [ -n "$2" ]; then
    # Comprobar si el segundo parámetro es un número (resolución)
    if [[ "$2" =~ ^[0-9]+$ ]]; then
        resolution="$2"
        # Si hay tercer parámetro, debe ser un idioma
        if [ -n "$3" ]; then
            lang="$3"
        fi
    else
        # No es un número, así que debe ser un idioma
        lang="$2"
        # Si hay tercer parámetro, debe ser una resolución
        if [ -n "$3" ]; then
            resolution="$3"
        fi
    fi
fi

echo "🔧 Configuración: Idioma=$lang, Resolución=${resolution}dpi"

# Verificar que el archivo de idioma exista
if ! tesseract --list-langs | grep -q "$lang"; then
    echo "❌ El idioma '$lang' no está instalado en Tesseract."
    echo "Instálalo con: sudo pacman -S tesseract-data-$lang"
    exit 1
fi

# Crea carpeta temporal en el directorio actual
tempdir="./ocr_temp_$(date +%s)"
mkdir -p "$tempdir"
echo "📁 Carpeta temporal: $tempdir"

# Determinar si es un archivo PDF o un directorio
if [ -f "$input_path" ] && [[ "$input_path" == *.pdf ]]; then
    # Es un PDF
    input_name=$(basename "$input_path" .pdf)
    echo "📄 Procesando archivo PDF: $input_path"
    
    # Convertir PDF a imágenes
    echo "🖼️ Convirtiendo páginas a imágenes (resolución: ${resolution}dpi)..."
    magick -density $resolution "$input_path" "$tempdir/page_%03d.png"

elif [ -d "$input_path" ]; then
    # Es un directorio
    input_name=$(basename "$input_path")
    echo "📂 Procesando directorio de imágenes: $input_path"
    
    # Copiar solo imágenes al directorio temporal
    echo "🔍 Buscando archivos de imagen en el directorio..."
    img_count=0
    
    # Extensiones de imagen comunes
    extensions=("jpg" "jpeg" "png" "tif" "tiff" "bmp" "gif")
    
    # Buscar imágenes y copiarlas al directorio temporal con nombres secuenciales
    # Corregimos el problema del subshell usando un array para almacenar los archivos
    for ext in "${extensions[@]}"; do
        # Almacenamos las rutas en un array
        image_files=()
        while IFS= read -r line; do
            image_files+=("$line")
        done < <(find "$input_path" -type f -iname "*.$ext" | sort)
        
        # Procesamos las imágenes encontradas
        for img in "${image_files[@]}"; do
            img_count=$((img_count+1))
            cp "$img" "$tempdir/page_$(printf "%03d" $img_count).png"
            echo "  - Encontrado: $(basename "$img")"
        done
    done
    
    if [ $img_count -eq 0 ]; then
        echo "❌ No se encontraron imágenes en el directorio."
        rm -rf "$tempdir"
        exit 1
    fi
    
    echo "✅ Se encontraron $img_count imágenes para procesar."
else
    echo "❌ El archivo o directorio '$input_path' no existe o no es válido."
    rm -rf "$tempdir"
    exit 1
fi

# Paso 2: OCR con Tesseract
echo "🔍 Aplicando OCR a las imágenes..."
output_pdfs=()
for img in "$tempdir"/page_*.png; do
    base="${img%.*}"
    echo "  - Procesando: $(basename "$img")"
    tesseract "$img" "$base" -l "$lang" pdf
    output_pdfs+=("$base.pdf")
done

# Verificar que se hayan generado PDFs
if [ ${#output_pdfs[@]} -eq 0 ]; then
    echo "❌ No se generaron archivos PDF. Verifica las imágenes de entrada."
    rm -rf "$tempdir"
    exit 1
fi

# Paso 3: Unir los PDFs
merged_pdf="$tempdir/merged.pdf"
echo "📎 Uniendo páginas OCR..."
pdfunite "${output_pdfs[@]}" "$merged_pdf"

# Paso 4: Optimizar el PDF
final_output="ocr_${input_name}.pdf"
echo "🗜️ Optimizando PDF final..."
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH \
   -sOutputFile="$final_output" "$merged_pdf"

# Mostrar información del tamaño
if [ -f "$input_path" ]; then
    original_size=$(du -h "$input_path" | cut -f1)
    echo "📊 Tamaño original: $original_size"
fi
final_size=$(du -h "$final_output" | cut -f1)
echo "📊 Tamaño final: $final_size"
echo "✅ OCR completo: $final_output"

# Limpiar
read -p "¿Eliminar archivos temporales ($tempdir)? [S/n]: " confirm
if [[ "$confirm" =~ ^[Ss]?$ ]]; then
    rm -rf "$tempdir"
    echo "🧹 Limpieza completada."
else
    echo "🗂️ Archivos temporales guardados en: $tempdir"
fi

