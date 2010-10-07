require File.join(File.dirname(__FILE__), '..', 'test_helper')
require 'ruby-debug'
#require 'test-helper'

class ExternalPathFinderTest < Test::Unit::TestCase

  context("testing the path finder") do
  
    setup { 
      Crabgrass::ExternalAPI.clear!
      Crabgrass::ExternalAPI.register(
                                      :overlay, {
                                        :model => TestModel,
                                        :methods =>
                                        { :find => "find",
                                          :paginate => "paginate"
                                        },
                                        :query_builder => {
                                          :keywords => {
                                            "text" => "",
                                            "tag" => "tag" },
                                          :key_value_separator => ":",
                                          :argument_separator => " "
                                        }
                                      }
                                    )
    }
    
    
  
    context("testing the convert method") do
      setup { 
        @some_crabgrass_paths = [[PathFinder::ParsedPath.new("tag/pakistan"),"tag:pakistan"], [PathFinder::ParsedPath.new("tag/pakistan/tag/maharatschi"), "tag:pakistan tag:maharatschi"]]
      }
      should("convert every path according to the specified rules")
      @some_crabgrass_paths.each do |p|
        parsed_path = Crabgrass::ExternalPathFinder.convert(:overlay, p[0])
        assert_equal parsed_path, p[1]
      end
    end
    
    
    context("testing the find method") do
      setup { 
        @result = Crabgrass::ExternalPathFinder.find(:overlay, PathFinder::ParsedPath.new("tag/pakistan"))
      }      
      should("return a collection of found items") { 
        assert_kind_of Array, @result
      }      
      
    end
    
    context("testing the paginate method") do
      setup {
        @result = Crabgrass::ExternalPathFinder.paginate(:overlay, PathFinder::ParsedPath.new("tag/pakistan"), { :per_page => 20, :page => 1})
      }
      
      should("return a collection of found items in the given size") { 
        assert_kind_of Array, @result
        assert_equal 20, @result.size
      }  
    end
    
  end
end
