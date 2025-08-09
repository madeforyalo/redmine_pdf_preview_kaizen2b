# frozen_string_literal: true
class RedminePdfPreviewKaizen2b::OfficeController < ApplicationController
  before_action :find_attachment
  before_action :authorize_view!

  def show
    settings = Setting['plugin_redmine_pdf_preview_kaizen2b'] || {}
    pdf_path = RedminePdfPreviewKaizen2b::Services::OfficeToPdf.new(@attachment, settings).call

    redirect_to(
      "#{Redmine::Utils.relative_url_root}/plugin_assets/redmine_pdf_preview_kaizen2b/pdfjs/web/viewer.html?" \
      "file=#{ERB::Util.url_encode(redmine_pdf_preview_kaizen2b_office_file_path(@attachment))}"
    )
  rescue => e
    Rails.logger.error("[office_preview] #{e.class}: #{e.message}")
    render_404
  end

  # sirve el PDF generado con permisos
  def file
    settings = Setting['plugin_redmine_pdf_preview_kaizen2b'] || {}
    pdf_path = RedminePdfPreviewKaizen2b::Services::OfficeToPdf.new(@attachment, settings).call
    send_file pdf_path, filename: File.basename(pdf_path), type: 'application/pdf', disposition: 'inline'
  end

  private

  def find_attachment
    @attachment = Attachment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize_view!
    render_403 unless @attachment.visible?
  end
end
