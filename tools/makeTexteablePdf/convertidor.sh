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
    echo "Uso: $0 archivo.pdf [idioma]"
    echo "Ejemplo: $0 documento.pdf spa"
    exit 1
fi

input_pdf="$1"
lang="${2:-eng}" # por defecto inglés

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

# Paso 1: Convertir PDF a imágenes
echo "🖼️ Convirtiendo páginas a imágenes..."
magick -density 300 "$input_pdf" "$tempdir/page_%03d.png"

# Paso 2: OCR con Tesseract
echo "🔍 Aplicando OCR..."
output_pdfs=()
for img in "$tempdir"/page_*.png; do
    base="${img%.*}"
    tesseract "$img" "$base" -l "$lang" pdf
    output_pdfs+=("$base.pdf")
done

# Paso 3: Unir los PDFs
final_output="ocr_$(basename "$input_pdf")"
echo "📎 Uniendo páginas OCR a $final_output ..."
pdfunite "${output_pdfs[@]}" "$final_output"

echo "✅ OCR completo: $final_output"

# Limpiar
read -p "¿Eliminar archivos temporales ($tempdir)? [S/n]: " confirm
if [[ "$confirm" =~ ^[Ss]?$ ]]; then
    rm -rf "$tempdir"
    echo "🧹 Limpieza completada."
else
    echo "🗂️ Archivos temporales guardados en: $tempdir"
fi

