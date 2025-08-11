# Redmine PDF Preview KaiZen2B

# Redmine PDF & Office Preview KaiZen2B

Este plugin para [Redmine](https://www.redmine.org/) permite la **visualización en línea** de archivos **PDF** y **documentos de Office**
(DOCX, XLSX, PPTX, etc.) directamente en el navegador.

## Características

- Vista previa de **PDF** usando [PDF.js](https://mozilla.github.io/pdf.js/).
- Conversión de documentos de Office a PDF usando **LibreOffice** en modo headless.
- Integración directa con la página de adjuntos de Redmine.
- Configuración flexible desde la interfaz de administración de Redmine.
- Soporte para:
  - Microsoft Word (.doc, .docx)
  - Microsoft Excel (.xls, .xlsx)
  - Microsoft PowerPoint (.ppt, .pptx)
  - OpenDocument (.odt, .ods, .odp)

## Requisitos

- **Redmine** 6.0 o superior.
- **LibreOffice** instalado en el servidor y accesible desde la línea de comandos (`soffice`).
- Ruby 3.2+

## Instalación

1. Clonar este repositorio dentro del directorio `plugins` de tu instalación de Redmine:

   ```bash
   cd /ruta/a/redmine/plugins
   git clone https://github.com/tu_usuario/redmine_pdf_preview_kaizen2b.git
   ```

2. Instalar dependencias:

   ```bash
   cd /ruta/a/redmine
   bundle install
   ```

3. Reiniciar Redmine:

   ```bash
   touch tmp/restart.txt
   ```

4. Configurar el plugin desde **Administración → Extensiones → Redmine PDF Preview KaiZen2B**.

   - **LibreOffice bin**: Ruta al ejecutable `soffice` (ejemplo: `/usr/bin/soffice`)
   - **UserInstallation (perfil)**: Carpeta temporal para el perfil de LibreOffice.
   - **HOME override**, **PATH override**, **TMPDIR**, **XDG_RUNTIME_DIR**: Ajustar según entorno.

## Uso

Una vez instalado y configurado, al abrir un archivo adjunto compatible se mostrará un enlace
para **"Vista previa"**. El plugin convertirá automáticamente el documento a PDF (si es Office)
y lo mostrará usando PDF.js.

## Créditos

- Basado en el trabajo original del plugin de vista previa PDF para Redmine.
- Modificado y extendido por **KaiZen2B** para soportar Office.

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.