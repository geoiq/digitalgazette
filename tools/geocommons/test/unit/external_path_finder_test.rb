require 'rubygems'
require File.dirname(__FILE__) + '/../../../../test/test_helper'
require 'path_finder'
require 'ruby-debug'
#require 'test-helper'

class ExternalPathFinderTest < Test::Unit::TestCase

  def setup
    Crabgrass::ExternalAPI.clear!
    Crabgrass::ExternalAPI.register(
                                     :overlay, {
                                        :model => TestModel,
                                        :methods =>
                                        { :find => "paginate"},
                                        :query_builder => {
                                          :keywords => {
                                            "text" => "",
                                          "tag" => "tag" },
                                          :key_value_separator => ":",
                                          :argument_separator => " "
                                          }
                                        }
                                    )
  end

  def test_convert
     some_crabgrass_paths = [[PathFinder::ParsedPath.new("tag/pakistan"),"tag:pakistan"], [PathFinder::ParsedPath.new("tag/pakistan/tag/maharatschi"), "tag:pakistan tag:maharatschi"]]
     some_crabgrass_paths.each do |p|
       parsed_path = Crabgrass::ExternalPathFinder.convert(:overlay, p[0])
       assert_equal parsed_path, p[1]
     end
  end

end
