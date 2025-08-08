# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  class Engine < ::Rails::Engine
    engine_name 'redmine_pdf_preview_kaizen2b'

    initializer 'redmine_pdf_preview_kaizen2b.assets' do
      # Redmine sirve /plugin_assets/<plugin> automáticamente
    end

    config.to_prepare do
      require_relative 'patches/attachments_controller_patch'
      AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch
    end
  end
end
