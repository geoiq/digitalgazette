require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../geocommons_test_helper'

class Geocommons::MapTest < Test::Unit::TestCase
  include GeocommonsTestHelper

  def setup
    fake_rest_api!
  end

  def teardown
    Geocommons::RestAPI.clear_fake_data
  end

  context "A Geocommons::Map" do
    should("be initializable with attributes") {
      map = Geocommons::Map.new(:title => 'foo', 'description' => 'foobar')
      assert_equal 'foo', map.title
      assert_equal 'foobar', map.description
    }

    context "with a author set as Geocommons::RestAPI would return it" do
      setup {
        @map = Geocommons::Map.new(:author => { 'name' => 'foo', 'url' => 'http://example.com/users/foo' })
      }

      should("have author_name set correctly") {
        assert_equal 'foo', @map.author_name
      }
      should("have author_url set correctly") {
        assert_equal 'http://example.com/users/foo', @map.author_url
      }
    end
  end

  context "Finding maps" do
    setup {
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
      @maps = Geocommons::Map.find({ })
      @count = Geocommons::Map.count({ })
    }

    should("give us the right count") {
      assert_equal @count, 2
    }

    should("give us the right amount of entries") {
      assert_equal @maps.size, 2
    }

    should("give us maps") {
      @maps.each do |map|
        assert map.kind_of?(Geocommons::Map)
      end
    }

    should("set the attributes correctly") {
      map1 = @maps.select { |map| map.id == 1 }.first
      map2 = @maps.select { |map| map.id == 2 }.first
      assert map1, "Map 1 not found. Maps: #{@maps.inspect}"
      assert map2, "Map 2 not found. Maps: #{@maps.inspect}"

      assert_equal 'author1', map1.author_name
      assert_equal 'http://example.com/users/author1', map1.author_url
      assert_equal 'First map', map1.title
      assert_equal 'First description', map1.description

      assert_equal 'author2', map2.author_name
      assert_equal 'http://example.com/users/author2', map2.author_url
      assert_equal 'Second map', map2.title
      assert_equal 'Second description', map2.description
    }
  end

  context "Finding a Map by ID" do
    setup {
      Geocommons::RestAPI.set_fake_get_data({
                                              'id' => '1',
                                              'author' => {
                                                'name' => 'author1',
                                                'url' => 'http://example.com/users/author1'
                                              },
                                              'title' => 'First map',
                                              'description' => 'First description'
                                            })
      @map = Geocommons::Map.find(1)
    }

    should("Find a map") {
      assert @map, "No Map!"
      assert @map.kind_of?(Geocommons::Map), "Returned value is not a map! (is: #{@map.inspect})"
    }

    should("have setup attributes correctly") {
      assert_equal 'author1', @map.author_name
      assert_equal 'http://example.com/users/author1', @map.author_url
      assert_equal 'First map', @map.title
      assert_equal 'First description', @map.description
    }
  end

  context "Finding a Map with format .kml" do
    setup {
      Geocommons::RestAPI.set_fake_get_data({
                                              'id' => '1',
                                              'author' => {
                                                'name' => 'author1',
                                                'url' => 'http://example.com/users/author1'
                                              },
                                              'title' => 'First map',
                                              'description' => 'First description'
                                            })
      @map = Geocommons::Map.find(1, 'kml')
    }
    should ("return the map in kml format") {
      assert @map
    }
  end
end
