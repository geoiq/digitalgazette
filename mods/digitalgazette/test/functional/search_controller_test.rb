require File.dirname(__FILE__) + '/../../../../test/test_helper'

require 'ruby-debug'

class SearchControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :page_terms

  def test_index
    return unless sphinx_working?

    login_as :blue

    get :index
    # NOTE for digital gazette mode
    assert assigns(:page_type)
    assert assigns(:tags)
    # end
    assert_response :success
 end

  def test_mysql_pagination
    return if sphinx_working?

    login_as :blue
    get :index
    assert assigns(:pages)
    assert assigns(:pages).total_pages
  end

  
  def test_typed_search
    #return unless sphinx_working?
    ["wiki", "asset"].each do |page_type|
      get :index, :path => ["type", page_type]
      assert assigns(:page_type) == page_type
      assert assigns(:pages)
      assigns(:pages).each do |page|
        assert page.class.name == (page_type+'_page').camelize
      end
      assert_select("section#pages")
    end
  end  
  
  def test_typed_search_xhr
    # test xhr requests
    ["wiki", "asset", "map"].each do |page_type|
      xhr :get, :index, :path => ["type", page_type]
      assert assigns(:page_type) == page_type
      assert assigns(:pages)
      assigns(:pages).each do |page|
        assert (page.class.name == (page_type+'_page').camelize)
      end
      assert @response.body.match("#{page_type}_list").kind_of?(MatchData)
    end
  end

  def test_search_with_preferred_type
    get :index, :path => ["preferred","asset","text","social"]
    assert assigns(:pages)
    assert_template "index"
    assert assigns(:preferred)
    assert_select "#?", /(asset|wiki|map|overlay)_list/ do |elements|
      assert elements.first.attributes["id"] = "#{assigns(:preferred)}_list"
    end
    # now there should be xhr requests fired
    # and in the view, there should be the preferred page type first
  end
  
  # NOTE only for digital gazette mode
  def test_external_search
    # return unless sphinx_working?
    # this only happens via xhr, and will throw errors if called otherwise
    xhr :get, :index, :path => ["type", "overlay"]
    assert assigns(:page_type) == "overlay"
    assert assigns(:pages)
    # check if any overlays are present
    overlays = true
    assigns(:pages).each do |page|
      assert page.kind_of?(Geocommons::RestAPI::Overlay)
    end
  end

  def test_text_search
    return unless sphinx_working?

    login_as :blue

    get :index, :path => ["text", "test"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert assigns(:pages).total_pages
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"
  end

  def test_text_search_and_sort
    return unless sphinx_working?

    login_as :blue

    get :index, :path => ["text", "test", "ascending", "owner_name"]
    assert_response :success
    assert assigns(:pages).any?, "should find a page"
    assert_not_nil assigns(:pages)[0].flag[:excerpt], "should generate an excerpt"

    # text "test" inside listings should be surrounded with <span class="search-excerpt"></span>
    assert_select "article span.search-excerpt", "test", "should highlight exceprts in markup"
  end

  def test_partial_recognition
    xhr :get, :index, :wrapper => 'pages/box'
    assert_template( "_box", "pages/box should have been rendered")
    xhr :get, :index, :widget => 'most_viewed'
    assert_template("_box", "pages/box should have been rendered")
    xhr :get, :index, :path => ["type","overlay"]
    assert_template('_list', "overlays/list should have been rendered")
    xhr :get, :index, :path => ["type","wiki"]
    assert_template('_list', "pages/list should have been rendered for type:wiki")
    assert_raises RuntimeError, "illegal widget should be reised for :widget => 'maeh'" do
      xhr :get, :index, :widget => "maeh"
    end
  end

  def test_illegal_wrapper_recognition
    assert_raises RuntimeError, "illegal partial should be raised for :wrapper => 'jenga'" do
      xhr :get, :index, :wrapper => "jenga"
    end
  end

end
