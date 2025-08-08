# frozen_string_literal: true
class RedminePdfPreviewKaizen2b::ViewerController < ApplicationController
  before_action :find_attachment
  before_action :authorize_view!

  def show
    @file_path = redmine_pdf_preview_kaizen2b_file_path(@attachment)
    render 'redmine_pdf_preview_kaizen2b/viewer/show', layout: !request.xhr?
  end

  def file
    send_file @attachment.diskfile,
              filename: @attachment.filename,
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
