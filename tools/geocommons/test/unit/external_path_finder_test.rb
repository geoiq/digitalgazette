require 'rubygems'
require File.dirname(__FILE__) + '/../../lib/crabgrass/path_finder/external_path_finder'
require 'test/unit'
require 'ruby-debug'
#require 'test-helper'

class ExternalPathFinderTest < Test::Unit::TestCase

  def setup
  end

  def test_convert
     some_crabgrass_paths = [["tag/pakistan","tag:pakistan"], ["tag/pakistan/tag/maharatschi", "tag:pakistan tag:maharatschi"]]
     some_crabgrass_paths.each do |p|
       parsed_path = Crabgrass::ExternalPathFinder.convert('overlay', p[0])
       assert_equal parsed_path, p[1]
     end
  end

end
