require 'rubygems'
require File.dirname(__FILE__) + '/../../lib/geocommons'
require File.dirname(__FILE__) + '/../../lib/geocommons/overlay'
require 'test/unit'
require 'json'
require 'ruby-debug'

# NOTE: this test relies on the data we got from the Geocommons - Service while we wrote it
# maybe this is the only reason, when your tests fail!
#

class GeocommonsOverlayTest < Test::Unit::TestCase

  def setup
      @valid_attributes = %w(short_classification name can_view can_edit author
                            can_download published icon_path id contributor
                            tags layer_size link description source bbox
                            created overlay_id detail_link)
      @overlay = Geocommons::Overlay
  end

  def test_valid_attributes
    assert_equal @overlay::VALID_ATTRIBUTES, @valid_attributes, "valid attributes should be the same in the api and the test"
    @valid_attributes.each do |attribute|
      assert @overlay.new.respond_to?(attribute.to_sym), "overlay should respond to #{attribute.to_sym}"
    end
    invalid_overlay = @overlay.new({ :foo => "bar"})
    assert_nil invalid_overlay.instance_variable_get(:"@foo")
  end

  # NOTE tests: def _find
  def test__find
    assert ! @overlay.find.empty?, "there should be some overlays, if the server is well configured"
    assert_kind_of Geocommons::Overlay, @overlay.find.first
  end

  def test_paginate
    results = @overlay.paginate(:query => '*')
    assert results.any?
    assert results.total_pages
  end

  def test_paginate_with_query
    # test without pagination params
    results_without_query = @overlay.paginate(:query => '*')
    results_with_query = @overlay.paginate(:query => 'social')
    assert results_without_query.size > results_with_query.size
    # test with pagination params
    results_with_pagination_params_page1 = @overlay.paginate(:query => '*', :per_page => 2, :page => 1)
    results_with_pagination_params_page2 = @overlay.paginate(:query => '*', :per_page => 2, :page => 2)
    assert results_with_pagination_params_page1.any?
    assert results_with_pagination_params_page1.size == 2
    assert results_with_pagination_params_page2.any?
    assert results_with_pagination_params_page2.size == 2
    assert results_with_pagination_params_page1 != results_with_pagination_params_page2
  end

  # FIXME 'not sure if :conditions => 'and' has any effect, but that's not a problem right now, we just won't use it
  def test_paginate_by_tag
    results_with_or_condition = @overlay.paginate_by_tag(["police","social"])
    results_with_and_condition = @overlay.paginate_by_tag(["police","social"], :condition => "and")
    assert results_with_or_condition.size >= results_with_and_condition.size, "there should be not more social policemen than policemen and societies"
    # test results without and condition
    results_with_or_condition.each do |result|
      assert (result.tags =~ /social/ || result.tags =~ /police/), "given two tags with or (default) condition should have results with any of the tags"
    end
    # test results with and condition
    results_with_and_condition.each do |result|
      assert (result.tags =~ /social/ and result.tags =~ /police/), "given two tags with and condition should return only results tagged with both tags"
    end
  end

  # NOTE: tests def find
  # NOTE: test_paginate and test_paginate_by_tag do pretty much also test _find
  def test_find

  end

end
