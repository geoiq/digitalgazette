require File.dirname(__FILE__) + '/../../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../geocommons_test_helper'

class Geocommons::OverlayTest < Test::Unit::TestCase
  include GeocommonsTestHelper

  def setup
    fake_rest_api!
  end

  def teardown
    Geocommons::RestAPI.clear_fake_data
  end

  context "A Geocommons::Overlay" do
    setup { @overlay = Geocommons::Overlay.new }
    should("have a bunch of attributes which can be set/get") {
      %w(short_classification name can_view can_edit
         author can_download published icon_path
         contributor tags layer_size link description
         source bbox created overlay_id detail_link).each do |attribute|
        value = rand
        @overlay.send("#{attribute}=", value)
        assert_equal value, @overlay.send(attribute), "attribute #{attribute} was not set correctly after calling #{attribute}="
      end
    }
  end

  context "Paginating overlays" do
    setup {
      Geocommons::RestAPI.set_fake_find_data('totalResults' => 2, 'entries' => [{
                                                                                  'name' => 'foo'
                                                                                }, {
                                                                                  'name' => 'bar'
                                                                                }
                                                                               ]) # not actually caring about the result...
    }

    context "Using paginate_by_tag" do
      setup { @overlays = Geocommons::Overlay.paginate_by_tag(['police', 'social']) }

      should("return a WillPaginate::Collection") {
        assert @overlays, "Nothing returned"
        assert @overlays.kind_of?(WillPaginate::Collection), "different result: #{@overlays.inspect}"

        assert @overlays.any?
        assert_equal 2, @overlays.count
        assert_equal 1, @overlays.total_pages
      }

      should("return the right data") {
        assert @overlays.select { |ol| ol.name == 'foo' }.any?, "'foo' not in collection"
        assert @overlays.select { |ol| ol.name == 'bar' }.any?, "'bar' not in collection"
      }

      should("have sent out a valid query for the tags") {
        assert_equal "tag:police or tag:social", Geocommons::RestAPI.last_find_options[:query]
      }
    end
  end
end
