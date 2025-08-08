# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  module Patches
    module AttachmentsControllerPatch
      OFFICE_EXT = %w[.doc .docx .xls .xlsx .ppt .pptx .odt .ods .odp].freeze

      def show
        @attachment = Attachment.find(params[:id])
        render_404 unless @attachment.visible?

        ext = File.extname(@attachment.filename).downcase

        if ext == '.pdf'
          return redirect_to(
            redmine_pdf_preview_kaizen2b_viewer_path(@attachment),
            allow_other_host: false
          )
        elsif OFFICE_EXT.include?(ext)
          return redirect_to(
            redmine_pdf_preview_kaizen2b_office_preview_path(@attachment),
            allow_other_host: false
          )
        end

        super
      end
    end
  end
end
