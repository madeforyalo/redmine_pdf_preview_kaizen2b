# Redmine PDF Preview KaiZen2B

Visor integrado de PDFs en Redmine usando **[PDF.js](https://mozilla.github.io/pdf.js/)**.  
Compatible con **Redmine 6.x (Rails 7)** y servidores Nginx/Apache sirviendo `plugin_assets` de forma directa.

## 📌 Características
- Redirección automática: al abrir un adjunto `.pdf`, Redmine carga el visor PDF.js integrado.
- Control de permisos: solo usuarios con acceso al adjunto pueden visualizarlo.
- PDF.js ya incluido dentro del plugin (no requiere descarga adicional).
- Servido de assets PDF.js desde `/plugin_assets` para mejor rendimiento.
- Compatible con las últimas versiones de PDF.js (`viewer.mjs`, `wasm`, etc.).
- Incluye **Rake task** para instalar y limpiar assets de forma sencilla.

---

## 🚀 Requisitos
- Redmine **>= 6.0.0** (Rails 7, Ruby 3.2.x).
- **Node.js** y **Yarn** instalados para gestión de assets de Redmine:
  ```bash
  sudo apt install nodejs npm
  sudo npm install -g yarn
  
📥 Instalación
Copiar el plugin en la carpeta de plugins de Redmine:

  
  cd /srv/redmine6/plugins
  git clone https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b.git

Instalar assets en public/plugin_assets:


 cd /srv/redmine6
 sudo -u redmine bundle exec rake redmine_pdf_preview_kaizen2b:assets RAILS_ENV=production
 
Reiniciar Redmine:

 touch tmp/restart.txt

 
🌐 Configuración en Nginx (ejemplo)
En tu bloque http { ... } de /etc/nginx/nginx.conf:

bash
 include       /etc/nginx/mime.types;
 default_type  application/octet-stream;

 types {
     application/javascript  mjs;
     application/wasm        wasm;
 }
En el bloque server { ... } de tu vhost:


   location ^~ /plugin_assets/ {
      alias /srv/redmine6/public/plugin_assets/;
      expires 30d;
      add_header Cache-Control "public, max-age=2592000";
      add_header Accept-Ranges bytes;
      add_header X-Content-Type-Options nosniff;
      try_files $uri =404;
   }
Recargar Nginx:


   sudo nginx -t && sudo systemctl reload nginx
🛠 Comandos disponibles
Copiar assets PDF.js a public/plugin_assets:


   bundle exec rake redmine_pdf_preview_kaizen2b:assets RAILS_ENV=production
   Limpiar assets instalados:



bundle exec rake redmine_pdf_preview_kaizen2b:clean RAILS_ENV=production
📂 Estructura relevante del plugin

redmine_pdf_preview_kaizen2b/
├── assets/
│   └── pdfjs/
│       ├── web/
│       └── build/
├── lib/
│   ├── patches/attachments_controller_patch.rb
│   ├── redmine_pdf_preview_kaizen2b/
│   │   └── engine.rb
│   └── tasks/redmine_pdf_preview_kaizen2b_assets.rake
├── app/
│   ├── controllers/...
│   └── views/...
└── README.md
📋 Notas
El visor funciona en cualquier navegador moderno que soporte ES modules y WebAssembly.

Probado en Redmine 6.0.6 con PDF.js incluido y Nginx 1.14+.

📜 Licencia
Este plugin sigue la misma licencia que Redmine (GPL v2).
