require 'rubygems'

begin
  require 'ruby-debug'
rescue LoadError => exc
  # no ruby debug installed
end

begin
  require 'leftright'
rescue LoadError => exc
  # no leftright installed
end

ENV["RAILS_ENV"] = "test"

$: << File.expand_path(File.dirname(__FILE__) + "/../")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require File.expand_path(File.dirname(__FILE__) + "/blueprints")

require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
end

require 'shoulda/rails'

module Tool; end


# require all helpers
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

# This is a testable class that emulates an uploaded file
# Even though this is exactly like a ActionController::TestUploadedFile
# i can't get the tests to work unless we use this.
class MockFile
  attr_reader :path
  def initialize(path); @path = path; end
  def size; 1; end
  def original_filename; @path.split('/').last; end
  def read; File.open(@path) { |f| f.read }; end
  def rewind; end
end

class ParamHash < HashWithIndifferentAccess
end

def mailer_options
  {:site => Site.new(), :current_user => users(:blue), :host => 'localhost',
  :protocol => 'http://', :port => '3000', :page => @page}
end

class Test::Unit::TestCase
  setup { Sham.reset }

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  ##########################################################################
  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper
  include FunctionalTestHelper
  include AssetTestHelper
  include SphinxTestHelper
  include SiteTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include DebugTestHelper

  # make sure the associations are at least defined properly
  def check_associations(m)
    @m = m.new
    m.reflect_on_all_associations.each do |assoc|
      assert_nothing_raised("#{assoc.name} caused an error") do
        @m.send(assoc.name, true)
      end
    end
    true
  end
end

# some special rules for integration tests
class ActionController::IntegrationTest
  # we load all fixtures because webrat integration test should see exactly
  # the same thing the user sees in development mode
  # using self.inherited to make sure
  # all fixtures are being loaded only if some integration tests are being defined
  def self.inherited(subclass)
    subclass.fixtures :all
  end
end
