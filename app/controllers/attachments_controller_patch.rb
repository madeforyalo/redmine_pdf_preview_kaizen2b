module AttachmentsControllerPatch
  def self.included(base)
    base.class_eval do
      # Guardamos el método original para poder invocarlo cuando no es un PDF
      alias_method :show_without_pdf_preview, :show

      # Interceptamos la acción "show" para mostrar una vista previa
      def show
        if @attachment.filename =~ /\.(pdf)\z/i
          render :pdf_view and return
        else
          show_without_pdf_preview
        end
      end
    end
  end
end

AttachmentsController.send(:include, AttachmentsControllerPatch)
