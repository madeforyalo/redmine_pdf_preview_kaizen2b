module AttachmentsControllerPatch
  def self.included(base)
    base.class_eval do
      alias_method :download_attachment_orig, :download

      # interceptamos la acción show
      def show
        if @attachment.filename =~ /\.(pdf)\z/i
          render :pdf_view and return
        else
          download_attachment_orig
        end
      end
    end
  end
end

AttachmentsController.send(:include, AttachmentsControllerPatch)
