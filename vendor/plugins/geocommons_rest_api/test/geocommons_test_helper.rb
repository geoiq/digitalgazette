

module GeocommonsTestHelper
  def fake_rest_api!
    Geocommons::RestAPI
    Kernel.load(File.join(File.dirname(__FILE__), 'fake_rest_api.rb'))
  end
end
