# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  class Engine < ::Rails::Engine
    engine_name 'redmine_pdf_preview_kaizen2b'

    config.to_prepare do
      Rails.logger.info "[kzn2b] loading attachments_controller_patch"
      require_dependency 'attachments_controller'
      require_relative 'patches/attachments_controller_patch'
      AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch
    end
  end
end
