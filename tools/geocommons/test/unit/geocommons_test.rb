require 'rubygems'
require File.dirname(__FILE__) + '/../../../../test/test_helper'
require File.dirname(__FILE__) + '/../../lib/geocommons'
require File.dirname(__FILE__) + '/../../lib/geocommons/rest_api'
require 'json'

GEOCOMMONS_HOST = "finder.digitalgazette.org"


class GeocommonsTest < Test::Unit::TestCase

  def setup
    @api = Geocommons::RestApi
  end

  def test_find
    assert_not_nil result = @api.find, ".find should return something"
    assert_kind_of Hash, result, "The result should be a Hash"
    assert result.keys.first == "totalResults", "the first key should be totalResults"
    assert result.keys[1] == "itemsPerPage", "the second key should be itemsPerPage"
    assert result.keys[2] == "entries", "the third key should be entries"
    assert result.keys[3] == "next", "the forth key should be next"
  end


end
