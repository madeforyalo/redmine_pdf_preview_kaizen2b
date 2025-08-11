# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  module Patches
    module AttachmentsControllerPatch
      OFFICE_EXT = %w[.doc .docx .xls .xlsx .ppt .pptx .odt .ods .odp].freeze

      def show
        Rails.logger.info "[kzn2b] attachments#show patched for id=#{params[:id]}"
        @attachment = Attachment.find(params[:id])
        return render_404 unless @attachment.visible?

        ext = File.extname(@attachment.filename).downcase

        if ext == '.pdf'
          redirect_to redmine_pdf_preview_kaizen2b_viewer_path(@attachment), allow_other_host: false
        elsif OFFICE_EXT.include?(ext)
          redirect_to redmine_pdf_preview_kaizen2b_office_preview_path(@attachment), allow_other_host: false
        else
          super
        end
      end
    end
  end
end
