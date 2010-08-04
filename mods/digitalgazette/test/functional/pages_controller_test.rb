require File.dirname(__FILE__) + '/../../../../test/test_helper'

require 'ruby-debug'

class SearchControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :page_terms

  context "PagesController" do

    context "with page type asset" do
      setup { get :index, :page_type => 'asset' }
      should "be successful" do
        assert_response :success
      end
    end

    context "with page type wiki" do
      setup { get :index, :page_type => 'wiki' }
        should "be successful" do
        assert_response :success
      end
    end

  end


end
