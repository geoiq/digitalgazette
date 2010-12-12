require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/application_helper.rb'
require File.join(Rails.root, 'vendor', 'plugins', 'geocommons_rest_api', 'test', 'geocommons_test_helper')

class MapsControllerTest < ActionController::TestCase
  include GeocommonsTestHelper

  def setup
    fake_rest_api!

    Geocommons::RestAPI.set_fake_find_data('totalResults' => 2,
                                           'entries' => [{
                                                           'id' => '1',
                                                           'author' => {
                                                             'name' => 'author1',
                                                             'url' => 'http://example.com/users/author1'
                                                           },
                                                           'title' => 'First map',
                                                           'description' => 'First description'
                                                         }, {
                                                           'id' => '2',
                                                           'author' => {
                                                             'name' => 'author2',
                                                             'url' => 'http://example.com/users/author2'
                                                           },
                                                           'title' => 'Second map',
                                                           'description' => 'Second description'
                                                         }])
    Geocommons::RestAPI.set_fake_get_data({
                                            'id' => '1',
                                            'author' => {
                                              'name' => 'author1',
                                              'url' => 'http://example.com/users/author1'
                                            },
                                            'title' => 'First map',
                                            'description' => 'First description'
                                          })
  end

  context "MapsController" do
    context "the index" do
      setup { get :index }
      should "be redirect to :all action" do
        assert_response :success
        assert_template "pages/index"
      end
    end

    context "show" do
      setup { get :show, :id => 1 }

      should "render the right template" do
        assert_template "maps/show"
      end

      should "assign @map" do
        assert (map = assigns(:map)), "@map not set"
        assert_equal map.id, 1
        assert_equal 'author1', map.author_name
      end
    end

    context "all" do
      setup { get :all}
      should "render the right template" do
        assert_template "pages/_list"
      end

      should "get maps" do
        assert (maps = assigns(:maps)), "should assign @maps"
        assert_equal 2, maps.size
      end
    end

    context "new" do
      setup { get :new }
      should "render the right template" do
        assert_template "maps/new"
      end
    end



    context "upload" do

    end


    # TODO write fixtures
    #
    # context "edit" do
    #   setup { get :edit, :id => }
    # end

  end


end
