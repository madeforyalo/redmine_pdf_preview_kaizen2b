require File.expand_path('../../test_helper', __FILE__)

class AttachmentsControllerPatchTest < ActionController::TestCase
  fixtures :attachments

  def setup
    @controller = AttachmentsController.new
  end

  def test_show_redirects_to_viewer_for_pdf
    attachment = attachments(:pdf_attachment)
    get :show, params: { id: attachment.id }
    assert_redirected_to redmine_pdf_preview_kaizen2b_viewer_path(attachment)
  end

  def test_show_redirects_to_office_preview_for_docx
    attachment = attachments(:docx_attachment)
    get :show, params: { id: attachment.id }
    assert_redirected_to redmine_pdf_preview_kaizen2b_office_preview_path(attachment)
  end
end
