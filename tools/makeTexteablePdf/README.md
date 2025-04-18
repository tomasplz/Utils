# Convertidor PDF Texteado

Herramienta para convertir archivos PDF escaneados a PDF con texto reconocido (texteado) mediante OCR.

## Descripción

Este script convierte documentos PDF escaneados (o imágenes) en documentos PDF con texto buscable. Utiliza Tesseract OCR para extraer el texto de las imágenes y genera un nuevo PDF que mantiene la apariencia original pero permite copiar texto, buscar palabras y es indexable.

## Requisitos

El script necesita las siguientes dependencias:
- `tesseract` - Motor de OCR
- `imagemagick` - Para procesar imágenes
- `poppler` (para el comando `pdfunite`) - Manipulación de PDFs
- `ghostscript` - Procesamiento de PDFs

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
./convertidor.sh archivo.pdf [idioma]
```

### Parámetros:

- `archivo.pdf` - Ruta al archivo PDF a procesar (obligatorio)
- `idioma` - Código de idioma de Tesseract (opcional, predeterminado: eng)

### Ejemplos:

```bash
# OCR en inglés (predeterminado)
./convertidor.sh documento.pdf

# OCR en español
./convertidor.sh documento.pdf spa

# OCR en francés
./convertidor.sh documento.pdf fra
```

## Funcionamiento

1. Verifica que todas las dependencias estén instaladas
2. Convierte el PDF en imágenes de alta resolución
3. Aplica OCR a cada imagen con el idioma especificado
4. Une los resultados en un único PDF con texto
5. Guarda el archivo resultante como `ocr_[nombre_original].pdf`

## Notas

- El proceso puede tomar tiempo dependiendo del tamaño y la complejidad del documento
- Por defecto se crea una carpeta temporal para el procesamiento que puede ser eliminada al finalizar
- La calidad del OCR depende de la claridad del documento original 