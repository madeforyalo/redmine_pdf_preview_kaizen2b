# Redmine PDF Preview KaiZen2B

Vista previa inline de PDFs dentro de Redmine 6.x usando PDF.js.

## Requisitos
- Redmine >= 6.0 (Rails 7)

## Instalación
1. Copiar este plugin a `REDMINE_ROOT/plugins/redmine_pdf_preview_kaizen2b`.
2. Descargar una release de **PDF.js** y copiar la carpeta `web/` a `plugins/redmine_pdf_preview_kaizen2b/assets/pdfjs/web`.
   - Debe quedar: `plugins/redmine_pdf_preview_kaizen2b/assets/pdfjs/web/viewer.html` (y sus assets).
3. Reiniciar Redmine (no necesita migraciones).

## Uso
- Al abrir un adjunto con extensión `.pdf`, serás redirigido automáticamente al visor integrado.

## Seguridad
- El acceso valida `attachment.visible?` antes de mostrar o servir el archivo.

## Notas
- Si preferís no redirigir automáticamente, podés reemplazar el patch por un hook de vista que agregue un botón "Ver PDF".
