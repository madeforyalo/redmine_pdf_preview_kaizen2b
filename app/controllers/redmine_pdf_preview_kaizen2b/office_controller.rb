# frozen_string_literal: true

class RedminePdfPreviewKaizen2b::OfficeController < ApplicationController
  before_action :find_attachment
  before_action :authorize_view!

  def show
    begin
      RedminePdfPreviewKaizen2b::Services::OfficeToPdf.new(@attachment, Setting['plugin_redmine_pdf_preview_kaizen2b']).call
      @file_path = redmine_pdf_preview_kaizen2b_office_file_path(@attachment)
      render 'redmine_pdf_preview_kaizen2b/viewer/show', layout: !request.xhr?
    rescue => e
      Rails.logger.error("[office_preview] #{e.message}")
      render_404
    end
  end

  def file
    begin
      pdf_path = RedminePdfPreviewKaizen2b::Services::OfficeToPdf.new(@attachment, Setting['plugin_redmine_pdf_preview_kaizen2b']).call
    rescue => e
      Rails.logger.error("[office_preview] #{e.message}")
      return render_404
    end
    send_file pdf_path,
              filename: File.basename(pdf_path),
              type: 'application/pdf',
              disposition: 'inline'
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
