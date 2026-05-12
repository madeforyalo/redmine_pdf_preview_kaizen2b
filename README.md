# Redmine PDF & Office Preview — KaiZen2B

Plugin para [Redmine](https://www.redmine.org/) que permite la **visualización en línea** de archivos **PDF** y **documentos Office** directamente en el navegador, sin necesidad de descargarlos.

## Características

- Vista previa de **PDF** usando [PDF.js](https://mozilla.github.io/pdf.js/) embebido en un iframe.
- Conversión automática de documentos **Office → PDF** usando **LibreOffice** en modo headless, con caché para evitar reconversiones.
- Intercepta el clic sobre cualquier adjunto compatible en Redmine — sin cambios en las vistas ni en los modelos de Redmine.
- Compatible con **Redmine 6.x** (Rails 7.1+, Zeitwerk).
- Formatos soportados:
  - PDF nativo (`.pdf`)
  - Microsoft Word (`.doc`, `.docx`)
  - Microsoft Excel (`.xls`, `.xlsx`)
  - Microsoft PowerPoint (`.ppt`, `.pptx`)
  - OpenDocument (`.odt`, `.ods`, `.odp`)

## Requisitos

| Componente | Versión mínima |
|---|---|
| Redmine | 6.0 |
| Ruby | 3.2 |
| Rails | 7.1 |
| LibreOffice | 7.x (instalado en el servidor) |

## Prerequisitos del servidor

Estos pasos deben completarse **antes** de instalar el plugin. Se asume un servidor Debian/Ubuntu con Apache2 y Passenger.

### Apache2 con mod_passenger

```bash
apt-get install -y libapache2-mod-passenger
a2enmod passenger
```

### LibreOffice

```bash
apt-get install -y libreoffice
```

### Directorios y permisos

El proceso de Redmine corre como `www-data`. Los tres directorios siguientes deben existir y pertenecerle:

```bash
# Perfil temporal de LibreOffice
mkdir -p /tmp/libreoffice_profile
chown www-data:www-data /tmp/libreoffice_profile

# Caché de PDFs generados por el plugin
mkdir -p /srv/redmine/tmp/pdf_previews
chown www-data:www-data /srv/redmine/tmp/pdf_previews

# Caché de dconf requerida por LibreOffice al correr como www-data
mkdir -p /var/www/.cache/dconf
chown www-data:www-data /var/www/.cache/dconf
```

### ImageMagick — habilitar procesamiento de PDF

Editar `/etc/ImageMagick-6/policy.xml` y reemplazar la línea que restringe el coder PDF:

```xml
<policy domain="coder" rights="read|write" pattern="PDF" />
```

### Assets de PDF.js — copia manual (si rake no está disponible)

Si `bundle exec rake redmine:plugins:assets` no funciona en tu entorno, copiá los assets directamente:

```bash
cp -r plugins/redmine_pdf_preview_kaizen2b/assets/pdfjs \
      public/plugin_assets/redmine_pdf_preview_kaizen2b/
```

### Reinicio después de cambios

Ante cualquier cambio en el plugin o en la configuración, reiniciar Apache y abrir una **pestaña de incógnito** para forzar que Passenger recargue la aplicación:

```bash
systemctl restart apache2
```

> La pestaña de incógnito evita que la sesión cacheada de tu navegador te muestre la versión anterior.

---

## Instalación

### 1. Clonar el plugin

```bash
cd /ruta/a/redmine/plugins
git clone https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b.git
```

### 2. Instalar dependencias

```bash
cd /ruta/a/redmine
bundle install
```

### 3. Publicar los assets de PDF.js

Este paso es obligatorio — sin él el visor no aparece.

```bash
bundle exec rake redmine:plugins:assets RAILS_ENV=production
```

Esto copia los archivos de PDF.js a `public/plugin_assets/redmine_pdf_preview_kaizen2b/`.

### 4. Reiniciar Redmine

```bash
touch tmp/restart.txt
# o bien: systemctl restart redmine (según tu entorno)
```

### 5. Configurar el plugin

Ve a **Administración → Extensiones → Redmine PDF Preview KaiZen2B** y ajusta:

| Parámetro | Descripción | Ejemplo |
|---|---|---|
| `LibreOffice binary` | Ruta al ejecutable `soffice` | `/usr/bin/libreoffice` |
| `LibreOffice profile dir` | Carpeta de perfil temporal para LibreOffice | `/tmp/libreoffice_profile` |
| `HOME override` | Variable `HOME` inyectada al proceso soffice | `/var/www` |
| `PATH override` | Variable `PATH` inyectada al proceso soffice | `/usr/bin:/bin` |
| `TMPDIR` | Directorio temporal | `/tmp` |
| `XDG_RUNTIME_DIR` | Variable requerida por LibreOffice en Linux | `/tmp` |
| `Conversion timeout` | Segundos máximos para la conversión | `60` |
| `Cache directory` | Ruta relativa a la raíz de Redmine donde se guardan los PDF generados | `tmp/pdf_previews` |

## Cómo funciona

```
Usuario hace clic en un adjunto
        │
        ▼
AttachmentsController#show  ← patch del plugin (vía prepend)
        │
        ├─ extensión .pdf  ──────────────────► ViewerController#show
        │                                             │
        ├─ extensión Office (.docx, .xlsx…) ──► OfficeController#show
        │                                             │ convierte con LibreOffice
        │                                             │ guarda en caché
        │                                             ▼
        │                                      ViewerController#show (reusar vista)
        │
        └─ cualquier otro formato ──────────── comportamiento original de Redmine
```

El visor PDF carga un `<iframe>` con **PDF.js** (`viewer.html`), que a su vez solicita el binario del PDF a través de rutas protegidas por los permisos de visibilidad de Redmine (`@attachment.visible?`).

## Rutas del plugin

| Método | Path | Acción | Descripción |
|---|---|---|---|
| GET | `/pdf_preview/:id` | `viewer#show` | Muestra el visor PDF.js para un PDF nativo |
| GET | `/pdf_preview/:id/file` | `viewer#file` | Sirve el binario del PDF (requiere permisos) |
| GET | `/office_preview/:id` | `office#show` | Convierte Office→PDF y muestra el visor |
| GET | `/office_preview/:id/file` | `office#file` | Sirve el PDF convertido (requiere permisos) |

## Caché de conversiones

Los PDFs generados se guardan en `<cache_dir>/<attachment_id>/<nombre>.pdf`. Si el archivo ya existe, se sirve directamente sin volver a lanzar LibreOffice.

Para limpiar la caché manualmente:

```bash
rm -rf /ruta/a/redmine/tmp/pdf_previews/
```

## Estructura del plugin

```
redmine_pdf_preview_kaizen2b/
├── app/
│   ├── controllers/
│   │   └── redmine_pdf_preview_kaizen2b/
│   │       ├── viewer_controller.rb   # Sirve PDFs nativos
│   │       └── office_controller.rb  # Convierte Office y sirve el resultado
│   └── views/
│       ├── redmine_pdf_preview_kaizen2b/viewer/show.html.erb  # Iframe PDF.js
│       └── settings/_redmine_pdf_preview_kaizen2b.html.erb   # Formulario de config
├── assets/
│   └── pdfjs/                         # PDF.js embebido (viewer.html + worker)
├── config/
│   └── routes.rb
├── lib/
│   └── redmine_pdf_preview_kaizen2b/
│       ├── engine.rb                  # Aplica el patch vía config.to_prepare
│       ├── patches/
│       │   └── attachments_controller_patch.rb  # Intercepta show por extensión
│       └── services/
│           └── office_to_pdf.rb       # Lógica de conversión con LibreOffice
└── init.rb                            # Registro del plugin en Redmine
```

## Cambios respecto a versiones anteriores

### v1.1.0 — Compatibilidad con Redmine 6.x / Rails 7.1+

- **Eliminado `require_dependency`**: Esta llamada fue removida en Rails 7.1. El engine ahora usa `require` con ruta absoluta dentro de `config.to_prepare`.
- **Patch aplicado una sola vez**: Se eliminaron los bloques redundantes en `init.rb` (`Rails.configuration.to_prepare` y `after_initialize`). El engine es el único responsable de aplicar el patch.
- **`OfficeController` corregido**: El archivo tenía la clase definida dos veces, lo que causaba comportamiento indefinido en Ruby. Quedó una sola definición limpia.
- **Partial de settings unificado**: Existían dos partials con contenido similar (`_redmine_pdf_preview_kaizen2b.html.erb` y `_redmine_pdf_preview_kaizen2b_settings.html.erb`). Se eliminó el duplicado; Redmine carga únicamente el indicado en `init.rb`.

## Créditos

Desarrollado por **KaiZen2B — Gonzalo Rojas** ([kaizen2b.com](https://kaizen2b.com)).

## Licencia

MIT. Consulta el archivo `LICENSE` para más detalles.
