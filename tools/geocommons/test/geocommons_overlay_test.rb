require 'rubygems'
require File.dirname(__FILE__) + '/../lib/geocommons'

require 'test/unit'
require 'json'
require 'ruby-debug'

# NOTE: this test relies on the data we got from the Geocommons - Service while we wrote it
# maybe this is the only reason, when your tests fail!
#

GEOCOMMONS_HOST = "finder.digitalgazette.org"

class GeocommonsOverlayTest < Test::Unit::TestCase

  def setup
      @valid_attributes = %w(short_classification name can_view can_edit author
                            can_download published icon_path id contributor
                            tags layer_size link description source bbox
                            created overlay_id detail_link)
      @overlay = Geocommons::RestAPI::Overlay
  end

  def test_valid_attributes
    assert_equal @overlay::VALID_ATTRIBUTES, @valid_attributes, "valid attributes should be the same in the api and the test"
    @valid_attributes.each do |attribute|
      assert @overlay.new.respond_to?(attribute.to_sym), "overlay should respond to #{attribute.to_sym}"
    end
    invalid_overlay = @overlay.new({ :foo => "bar"})
    assert_nil invalid_overlay.instance_variable_get(:"@foo")
  end

  def test_gecommons_host_vailable
    assert (GEOCOMMONS_HOST), "geocommons host should be available"
    assert !(GEOCOMMONS_HOST).empty?, "geocommons host should not be empty"
  end

  # NOTE tests: def _find
  def test__find
    assert ! @overlay.find.empty?, "there should be some overlays, if the server is well configured"
    assert_kind_of Geocommons::RestAPI::Overlay, @overlay.find.first
  end



  # FIXME 'not sure if :conditions => 'and' has any effect, but that's not a problem right now, we just won't use it
  def test_paginate_by_tag
    assert results = @overlay.paginate_by_tag("police","social").size >= @overlay.paginate_by_tag("police","social", :conditions => "and").size, "there should be not more social policemen than policemen and societies"
    results.each do |result|
      assert  (result.tags.include?("social") and result.tags.include?("police"))
    end
  end

  # NOTE: tests def find
  def test_find

  end

  def test_paginate

  end

end
