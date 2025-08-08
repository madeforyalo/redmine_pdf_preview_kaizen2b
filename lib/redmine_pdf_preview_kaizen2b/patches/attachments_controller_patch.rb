# frozen_string_literal: true
module RedminePdfPreviewKaizen2b
  module Patches
    module AttachmentsControllerPatch
      def show
        @attachment = Attachment.find(params[:id])
        render_404 unless @attachment.visible?

        if File.extname(@attachment.filename).downcase == '.pdf'
          return redirect_to(
            redmine_pdf_preview_kaizen2b_viewer_path(@attachment),
            allow_other_host: false
          )
        end

        super
      end
    end
  end
end
