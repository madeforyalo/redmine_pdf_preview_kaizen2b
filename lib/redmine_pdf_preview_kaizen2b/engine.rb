# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  class Engine < ::Rails::Engine
    engine_name 'redmine_pdf_preview_kaizen2b'

    config.to_prepare do
      require Rails.root.join(
        'plugins', 'redmine_pdf_preview_kaizen2b',
        'lib', 'redmine_pdf_preview_kaizen2b', 'patches', 'attachments_controller_patch'
      ).to_s
      AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch
      Rails.logger.info "[kzn2b] attachments_controller_patch applied"
    rescue => e
      Rails.logger.error "[kzn2b] error loading patch: #{e.class}: #{e.message}"
      raise
    end
  end
end
