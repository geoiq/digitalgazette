require 'test/unit'
require 'rubygems'

# Add other plugins to load path
PLUGINS_DIR = File.expand_path(File.dirname(__FILE__) + "/../..")
Dir.new(PLUGINS_DIR).each do |f|
  path = "#{PLUGINS_DIR}/#{f}/lib"
  $LOAD_PATH << path if File.directory?(path)
end

puts "Load path: #{$LOAD_PATH.inspect}"
require 'geocommons_search'
require 'shoulda'
require 'mocha'

class GeocommonsSearchTest < Test::Unit::TestCase

  def self.should_map(value, result)
    should "map #{value} in query to #{result} field" do
      assert_equal result, GeocommonsSearch::Search.map_field(value)
    end
  end

  should_map("user_id_i", "user_id_i")
  should_map("shared_b", "shared_b")
  should_map("description", "description_t")
  should_map("title",  "title_t")
  should_map("tag", "indexed_tags_t")
  should_map("xtagx", "indexed_tags_t")
  should_map("lineage", "lineage_t")
  should_map("source", "lineage_t")
  should_map("name", "overlay_name_t")
  should_map("xoverlayx", "overlay_name_t")
  should_map("user", "user_login_t")
  should_map("xcreatorx", "user_login_t")
  should_map("xuploaderx", "user_login_t")
  should_map("xloginx", "user_login_t")
  should_map("xcontactx", "contact_name_t")
  should_map("minlat", "min_latitude_rf")
  should_map("minlng", "min_longitude_rf")
  should_map("maxlat", "max_latitude_rf")
  should_map("maxlng", "max_longitude_rf")

  should_map("xyz", nil)

  def empty_solr_response
    Solr::Response::Standard.new(%Q({
      'responseHeader' => {'status' => 0, 'QTime' => 1},
      'response' => {'numFound' => 0, 'start' => 0, 'docs' => []}
    }))
  end

  should "clean query before executing" do
    GeocommonsSearch::Search.expects(:clean_query).returns("test")
    ActsAsSolr::Post.expects(:execute).returns(empty_solr_response)
    GeocommonsSearch::Search.execute("")
  end

  def self.should_query_for(re, desc = nil, &block)
    unless desc
      desc = re.to_s
    end
    re = Regexp.compile(re) if re.kind_of? String
    should "query for #{desc}" do
      Solr::Request::Standard.expects(:new).with { |opts|
        re =~ opts[:query]
      }
      ActsAsSolr::Post.expects(:execute).returns(empty_solr_response)
      block.bind(self).call
    end
  end

  should_query_for(/type_s:overlay\s+OR\s+type_s:overlay_meta/, "models in :models option") do
    GeocommonsSearch::Search.execute("", :models => ['overlay', 'overlay_meta'])
  end

  should_query_for(/user_login_t:joe\s+OR\s+shared_b:true/, "user or shared") do
    GeocommonsSearch::Search.execute("", :user_login => 'joe', :show_shared => true)
  end

  should_query_for(/user_login_t:joe\s+AND\s+shared_b:true/, "user and shared") do
    GeocommonsSearch::Search.execute("", :user_login => 'joe', :show_only_shared => true)
  end

  should_query_for(/user_login_t:joe/, "user only") do
    GeocommonsSearch::Search.execute("", :user_login => 'joe')
  end

  should_query_for(/shared_b:true/, "shared only") do
    GeocommonsSearch::Search.execute("", :show_shared => true)
  end

  should_query_for(/xyz:"a"\s+OR\s+xyz:"b"/, "field in set of string values using :wherein option") do
    GeocommonsSearch::Search.execute("", :wherein => { 'xyz' => ['a','b']})
  end

  should_query_for(/xyz:5\s+OR\s+xyz:6/, "field in set of number values using :wherein option") do
    GeocommonsSearch::Search.execute("", :wherein => { 'xyz' => [5, 6]})
  end

  should_query_for(/\(x:5\)\s+AND\s+\(y:6\)/, "multiple whereins") do
    GeocommonsSearch::Search.execute("", :wherein => { 'x' => [5], 'y' => [6]})
  end

  should_query_for(/is_copy_b:false/, "originals by default if no user") do
    GeocommonsSearch::Search.execute("")
  end

  should_query_for(/^\w*$+/, "copies when requested") do
    GeocommonsSearch::Search.execute("", :show_copies => true)
  end

  def self.should_query_for_field_in_range(name, min, max, &block)
    should_query_for("#{name}:\\[#{min} TO #{max}\\]", "#{name} in range", &block)
  end

  context "with bounding box :in option" do
    setup do
      @box = [-1.0, -2.0, 3.0, 4.0]
    end
    should_query_for_field_in_range('min_latitude_rf', -1.0, 3.0) do
      GeocommonsSearch::Search.execute("", :in => @box)
    end
    should_query_for_field_in_range('max_latitude_rf', -1.0, 3.0) do
      GeocommonsSearch::Search.execute("", :in => @box)
    end
    should_query_for_field_in_range('min_longitude_rf', -2.0, 4.0) do
      GeocommonsSearch::Search.execute("", :in => @box)
    end
    should_query_for_field_in_range('max_longitude_rf', -2.0, 4.0) do
      GeocommonsSearch::Search.execute("", :in => @box)
    end
  end

  context "with bbox query" do
    setup do
      @query = 'bbox:[-1.0, -2.0, 3.0, 4.0]'
    end
    should_query_for_field_in_range('min_latitude_rf', -1.0, 3.0) do
      GeocommonsSearch::Search.execute(@query)
    end
    should_query_for_field_in_range('max_latitude_rf', -1.0, 3.0) do
      GeocommonsSearch::Search.execute(@query)
    end
    should_query_for_field_in_range('min_longitude_rf', -2.0, 4.0) do
      GeocommonsSearch::Search.execute(@query)
    end
    should_query_for_field_in_range('max_longitude_rf', -2.0, 4.0) do
      GeocommonsSearch::Search.execute(@query)
    end
  end
end
