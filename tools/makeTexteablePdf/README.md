# Convertidor PDF Texteado

Herramienta para convertir a PDF con texto reconocido (texteado) mediante OCR, con optimización de tamaño. Funciona con archivos PDF escaneados o con directorios que contienen imágenes.

## Descripción

Este script convierte documentos PDF escaneados o imágenes en documentos PDF con texto buscable. Utiliza Tesseract OCR para extraer el texto de las imágenes y genera un nuevo PDF que mantiene la apariencia original pero permite copiar texto, buscar palabras y es indexable. Incluye un paso de optimización para reducir el tamaño del archivo resultante.

## Requisitos

El script necesita las siguientes dependencias:
- `tesseract` - Motor de OCR
- `imagemagick` - Para procesar imágenes
- `poppler` (para el comando `pdfunite`) - Manipulación de PDFs
- `ghostscript` - Procesamiento y optimización de PDFs

## Instalación

En sistemas basados en Arch Linux:

```bash
sudo pacman -S tesseract imagemagick poppler ghostscript
```

Para otros idiomas además del inglés, instala los paquetes de datos correspondientes:

```bash
sudo pacman -S tesseract-data-spa  # Para español
sudo pacman -S tesseract-data-fra  # Para francés
# etc...
```

### Permisos de ejecución

Para poder ejecutar el script, es necesario darle permisos de ejecución:

```bash
chmod +x convertidor.sh
```

## Uso

```bash
./convertidor.sh archivo.pdf|directorio [idioma|resolución] [resolución|idioma]
```

### Parámetros:

- `archivo.pdf|directorio` - Ruta al archivo PDF o directorio con imágenes (obligatorio)
- `idioma|resolución` - Código de idioma o resolución en DPI (opcional)
- `resolución|idioma` - Resolución en DPI o código de idioma (opcional)

El script detecta automáticamente si el segundo parámetro es un idioma o una resolución:
- Si es un número, se interpreta como resolución y usa inglés por defecto
- Si no es un número, se interpreta como código de idioma

### Ejemplos:

```bash
# OCR de un PDF en inglés (predeterminado) con resolución predeterminada (150dpi)
./convertidor.sh documento.pdf

# OCR de un PDF en español con resolución predeterminada
./convertidor.sh documento.pdf spa

# OCR de un PDF en español con resolución personalizada
./convertidor.sh documento.pdf spa 300

# OCR de un PDF con resolución personalizada (100dpi) en inglés
./convertidor.sh documento.pdf 100

# OCR de un directorio de imágenes en español
./convertidor.sh carpeta_imagenes/ spa

# OCR de un directorio de imágenes con resolución baja (90dpi) en inglés
./convertidor.sh carpeta_imagenes/ 90
```

## Funcionamiento

### Procesamiento de PDF:
1. Verifica que todas las dependencias estén instaladas
2. Convierte el PDF en imágenes con la resolución especificada
3. Aplica OCR a cada imagen con el idioma especificado
4. Une los resultados en un único PDF con texto
5. Optimiza el PDF final para reducir su tamaño
6. Guarda el archivo resultante como `ocr_[nombre_original].pdf`

### Procesamiento de directorio con imágenes:
1. Busca archivos de imagen en el directorio (jpg, jpeg, png, tif, tiff, bmp, gif)
2. Ordena las imágenes alfabéticamente
3. Procesa cada imagen con OCR 
4. Une todos los resultados en un único PDF
5. Optimiza el PDF final
6. Guarda el archivo resultante como `ocr_[nombre_directorio].pdf`

## Notas

- La resolución recomendada es entre 150-300 DPI. Valores más bajos generan archivos más pequeños pero con menor calidad
- El proceso puede tomar tiempo dependiendo del tamaño y la complejidad del documento
- Por defecto se crea una carpeta temporal para el procesamiento que puede ser eliminada al finalizar
- La optimización reduce significativamente el tamaño del archivo manteniendo una calidad aceptable
- La calidad del OCR depende de la claridad del documento original 