require File.expand_path('../../test_helper', __FILE__)

class AttachmentsControllerPatchTest < ActionController::TestCase
  fixtures :attachments

  def setup
    @controller = AttachmentsController.new
  end

  def test_show_renders_pdf_view_for_pdf
    get :show, params: { id: attachments(:pdf_attachment).id }
    assert_template 'pdf_view'
  end
end
