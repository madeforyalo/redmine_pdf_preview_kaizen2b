# Redmine PDF Preview KaiZen2B

This Redmine plugin enables inline preview of PDF attachments using [PDF.js](https://mozilla.github.io/pdf.js/).

## Installation
1. Place the plugin directory into your Redmine `plugins` folder, typically `REDMINE_ROOT/plugins`.
2. Obtain a PDF.js distribution (e.g. from the [PDF.js releases](https://github.com/mozilla/pdf.js/releases)).
3. Copy the `web` folder from the PDF.js build into `assets/pdfjs` inside this plugin so that `assets/pdfjs/web/viewer.html` exists.
4. Restart Redmine so the plugin and assets are picked up.

## Usage
After installation, opening a PDF attachment will display it in the PDF.js viewer instead of forcing a download. Other attachment types continue to download normally.

## Notes
- The plugin expects PDF.js assets under `assets/pdfjs/web`. These files are **not** included in the repository and must be provided manually.

## Development
Internally the plugin patches `AttachmentsController#show` and renders a custom view when the attachment filename ends in `.pdf`.
