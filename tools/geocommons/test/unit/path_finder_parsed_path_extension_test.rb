
require 'rubygems'
require File.dirname(__FILE__) + '/../../../../test/test_helper'
#require File.dirname(__FILE__) + '/../../lib/crabgrass/path_finder/external_path_finder'
require 'test/unit'
require 'ruby-debug'
require 'shoulda'
class PathFinderParsedPathExtenstionTest < ActiveSupport::TestCase
  
  context("given a query as a hash") { 
    setup{ @query = { :type => "wiki", :tag => "pakistan"}
      @path = PathFinder::ParsedPath.new(@query)
    }
      
    should("return a valid path") { 
      assert_equal [["tag", "pakistan"], ["type", "wiki"]], @path
      assert_kind_of PathFinder::ParsedPath, @path
    }
    
  }  
  
  
  context("given a path as an argument") { 
    setup{ @query = "type/wiki/tag/pakistan"
      @path = PathFinder::ParsedPath.new(@query)
    }
      
    should("look like a path") { 
      assert_equal @path, [["type","wiki"],["tag","pakistan"]]
    }

    
    context("testing the extension") { 
      
      context("testing add_types!") { 
        setup { @path.add_types! ["asset","overlay"]}
        should("look have added two types to the path") { 
          assert_equal @path.sort, [["type","wiki"],["tag","pakistan"],['type','overlay'],['type','asset']].sort
        }
      }
      
      
      context("testing keywords") { 
        setup { @args = @path.keywords}
        should("return an array of all keywords") {
          args = ["type","tag"]
          assert_equal args.sort, @args.sort
        }
        context("with a path with atomar keywords") { 
          setup { @path2 = PathFinder::ParsedPath.new("type/wiki/or/type/asset")}
          should("contain 'or' with :ignore_atoms => false") { 
            assert @path2.keywords({ :ignore_atoms => false}).include?("or")
          }
          should("not contain 'or' with :ignore_atoms => true") { 
            assert ! @path2.keywords({ :ignore_atoms => true}).include?("or")
          }
        }
      }
      
      
      context("testing remove_keyword") { 
        should("have removed tag from the path") { 
          assert_equal [["type","wiki"]], @path.remove_keyword("tag")
        }
      }
      
      context("testing all_args_for") { 
        setup { 
          @path = PathFinder::ParsedPath.new("type/wiki/type/asset/type/overlay")
          @args = @path.all_args_for("type")}
        should("return an array of types") {
          args = ["wiki","overlay","asset"]
          assert_equal args.sort, @args.sort
        }
      }
      
      context("testing keywords with args") { 
        setup { @path = PathFinder::ParsedPath.new("type/asset/type/wiki/type/overlay/tag/pakistan/tag/opiate/tag/fun")}
        should("return a hash") { 
          assert_kind_of Hash, @path.keywords_with_args
        }
        should("return the right keys") { 
          ["type","tag"].each do |key|
            @path.keywords_with_args.keys.include?(key)
          end
        }
        should("assign the right values") { 
          ["wiki","asset","overlay"].each do |t|
            assert @path.keywords_with_args["type"].include?(t)
          end
        }
        
      
      }
      
      
    }  
    

    
    
    
  }  
  
  
  
  
end
