require 'redmine'

Redmine::Plugin.register :redmine_pdf_preview_kaizen2b do
  name        'Redmine PDF Preview KaiZen2B'
  author      'Gonzalo Rojas'
  description 'Vista previa inline de PDFs usando PDF.js'
  version     '0.1.0'
  url         'https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b.git'
end

# parcheamos AttachmentsController al iniciar
Rails.configuration.to_prepare do
  require_dependency 'attachments_controller'
  require_dependency 'attachments_controller_patch'
end
