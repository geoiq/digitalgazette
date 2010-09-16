require 'rubygems'
#require File.dirname(__FILE__) + '/../../lib/crabgrass/path_finder/external_path_finder'
require 'test/unit'
require 'ruby-debug'
require 'shoulda'

class TestModel
  def paginate(args)
    return args
  end
end

class ExternalAPITest < Test::Unit::TestCase

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
                                            "tag" => "tag"
                                          },
                                          :argument_separator => " ",
                                        }
                                      }


                                    )
  end

  context("retrieving a api") {

    context("that does not exist"){
      should("return nothing") {
        assert_nil Crabgrass::ExternalAPI.for("something_that_does_not_exist")
      }
    }
    context("for our registered model") {
      setup { @api = Crabgrass::ExternalAPI.for(:overlay)
     }
      should("be available") {
        assert @api
      }
      context("the api") do
        should("have a name") {
            assert_equal @api.name, :overlay
          }
         should("have a valid map table") {
          assert_equal Crabgrass::ExternalAPI.registered_apis[:overlay], @api.map_table
        }
        should("assign a model") {
          assert @api.model == "overlay"
        }
        should("map the registered finder method") {
          assert @api.get_method(:find)
        }
        should("return an argument separator ") {
          assert @api.argument_separator
        }
        should("return the default key-value-separator, because we didn't set one") {
          assert_equal @api.key_value_separator, "="
        }

        should("call the corresponding method on the Test-Model") {
          args = "bla"
          assert_equal args, @api.call(:find,args)
        }

        # TODO test the load method!!

        context("and clearing again") do
          setup{ Crabgrass::ExternalAPI.clear!}
          should("have nothing left") {
            assert_nil Crabgrass::ExternalAPI.for(:overlay)
          }
        end
      end


    }



  }
end
