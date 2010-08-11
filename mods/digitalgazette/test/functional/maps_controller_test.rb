require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/application_helper.rb'
require File.dirname(__FILE__) + '/../../../../tools/geocommons/init.rb'
class MapsControllerTest < ActionController::TestCase
  
  
  context "MapsController" do
    context "the index" do
      setup { get :index }
      should "be successful" do
        assert_response :success
      end
      
      should "have the api available" do
        assert assigns(:api), "the @api should be there"
        assert assigns(:api).name.to_s == "map", "the @api should be the map api"
      end
      
      should "render the right template" do
        assert_template "maps/index"
        assert_select "#maker_map"
      end
      
      
      should "get tags and maps" do
        assert assigns(:maps), "should assign @maps"
        assert assigns(:tags), "should assign @tags"
      end
      
      should "assert popular and tags" do
        assert assigns(:popular), "should assign @popular"
        assert assigns(:tags), "should assign @tags"
      end
    end
    
    context "show" do
      setup { get :show}
      should "render the right template" do
        assert_template "maps/show"
      end
    
      should "get tags and maps" do
        assert assigns(:maps), "should assign @maps"
        assert assigns(:tags), "should assign @tags"
      end
      
      should "assign @map and @map_id" do
        assert assigns(:map)
        assert_equal assigns(:maps).last, assigns(:map)
        assert assigns(:map_id)
      end

      should "have the api available" do
        assert assigns(:api), "the @api should be there"
        assert assigns(:api).name.to_s == "map", "the @api should be the map api"
      end
      
      
    end
    
    context "all" do
      setup { get :all}
      should "have the api available" do
        assert assigns(:api), "the @api should be there"
        assert assigns(:api).name == "map", "the @api should be the map api"
      end
      
      should "render the right template" do
        assert_template "maps/all"
      end
      
      
    end
    
    context "new" do
      setup { get :new }
      should "have the api available" do
        assert assigns(:api), "the @api should be there"
        assert assigns(:api).name == "map", "the @api should be the map api"
      end
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
