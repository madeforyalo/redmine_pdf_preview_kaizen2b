# frozen_string_literal: true
require_relative 'lib/redmine_pdf_preview_kaizen2b/engine'

Redmine::Plugin.register :redmine_pdf_preview_kaizen2b do
  name        'Redmine PDF Preview KaiZen2B'
  author      'KaiZen2B'
  description 'Inline PDF preview in Redmine using PDF.js + Office→PDF'
  version     '1.1.0'
  url         'https://github.com/madeforyalo/redmine_pdf_preview_kaizen2b'
  author_url  'https://kaizen2b.com'
  requires_redmine version_or_higher: '6.0.0'

  settings partial: 'settings/redmine_pdf_preview_kaizen2b', default: {
    'lo_bin'          => '/usr/lib/libreoffice/program/soffice',
    'lo_profile'      => '/tmp/libreoffice_profile',
    'home_override'   => '/var/www',
    'path_override'   => '/usr/bin:/bin',
    'tmpdir'          => '/tmp',
    'xdg_runtime'     => '/tmp',
    'convert_timeout' => 60,
    'cache_dir'       => 'tmp/pdf_previews'
  }
end

# --- Asegurar el patch, SIEMPRE ---
Rails.configuration.to_prepare do
  Rails.logger.info "[kzn2b] applying attachments_controller_patch (to_prepare)"
  require_dependency 'attachments_controller'
  require Rails.root.join('plugins','redmine_pdf_preview_kaizen2b','lib',
                          'redmine_pdf_preview_kaizen2b','patches','attachments_controller_patch')
  AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch
end

Rails.application.config.after_initialize do
  # por si otro plugin hace prepend luego del boot,
  # lo volvemos a poner primero.
  Rails.logger.info "[kzn2b] re-applying attachments_controller_patch (after_initialize)"
  require_dependency 'attachments_controller'
  AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch
end
