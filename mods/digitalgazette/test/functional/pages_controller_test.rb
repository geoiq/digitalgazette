require File.dirname(__FILE__) + '/../../../../test/test_helper'

require 'ruby-debug'

class SearchControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites,
           :memberships, :user_participations, :group_participations,
           :pages, :page_terms

  context "SearchController" do
    setup { true }
    should "be true" do
      assert true
    end
  end


end
