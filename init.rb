require 'redmine'

Redmine::Plugin.register :redmine_pdf_preview_custom do
  name        'Redmine PDF Preview Custom'
  author      'Tu Empresa'
  description 'Vista previa inline de PDFs usando PDF.js'
  version     '0.1.0'
  url         'https://tu-repo.git'
end

# parcheamos AttachmentsController al iniciar
Rails.configuration.to_prepare do
  require_dependency 'attachments_controller'
  require_dependency 'attachments_controller_patch'
end
