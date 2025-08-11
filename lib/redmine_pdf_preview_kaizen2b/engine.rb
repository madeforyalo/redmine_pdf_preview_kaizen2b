# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  class Engine < ::Rails::Engine
    engine_name 'redmine_pdf_preview_kaizen2b'

    # Ejecuta en boot (production) y antes de cada reload (development)
    config.to_prepare do
      begin
        require_dependency 'attachments_controller'
        require Rails.root.join(
          'plugins', 'redmine_pdf_preview_kaizen2b',
          'lib', 'redmine_pdf_preview_kaizen2b', 'patches', 'attachments_controller_patch'
        )

        # Hacer prepend *otra vez* para asegurar que quede primero,
        # incluso si otro plugin hace prepend después.
        AttachmentsController.prepend RedminePdfPreviewKaizen2b::Patches::AttachmentsControllerPatch

        Rails.logger.info "[kzn2b] attachments_controller_patch PREPENDED (ancestors: #{AttachmentsController.ancestors.first(5)})"
      rescue => e
        Rails.logger.error "[kzn2b] error loading attachments_controller_patch: #{e.class}: #{e.message}"
        raise
      end
    end
  end
end
