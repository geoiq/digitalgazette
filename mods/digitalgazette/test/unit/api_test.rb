require 'yaml'
require 'test_helper'
require "#{RAILS_ROOT}/mods/digitalgazette/lib/digital_gazette/api"
class ApiTest < ActiveSupport::TestCase
  
  def setup
    @api = DigitalGazette::Api.new(:map)
    @yml = YAML.load(File.read("#{RAILS_ROOT}/mods/digitalgazette/api.yml"))
  end
  
  def test_attributes
    assert @api, "Api should exist"
    @yml['map'].each_pair do |k,v|
      assert_equal v, @api.instance_variable_get(:"@#{k}")
    end
  end
  
end
