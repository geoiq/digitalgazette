require File.dirname(__FILE__) + '/../../../../test/test_helper'

class WikiPageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :wikis, :groups, :sites

  def test_pdf_public_not_logged_in
    do_test_wiki_download(:pdf, pages(:public_wiki))
  end

  def test_pdf_public_logged_in
    login_as :orange
    do_test_wiki_download(:pdf, pages(:public_wiki))
  end

  def test_rtf_public_not_logged_in
    do_test_wiki_download(:rtf, pages(:public_wiki))
  end

  def test_rtf_public_logged_in
    login_as :orange
    do_test_wiki_download(:rtf, pages(:public_wiki))
  end


  private

  # only for pdf & rtf...
  def do_test_wiki_download(format, page)
    get format, :page_id => page.id
    assert_response :success
    headers = @controller.response.headers
    assert_equal "application/#{format}", headers['type']
    assert headers['Content-Disposition'] =~ /^attachment/
    assert headers['Content-Length'] > 0
  end
end
