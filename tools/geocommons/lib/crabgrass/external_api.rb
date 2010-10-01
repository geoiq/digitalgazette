        require 'rubygems'
        require 'open-uri'

module Crabgrass
  #
  #
  # ExternalAPI works just as a proxy to access
  # the right API for a certain ExternalPage - data model
  #
  # In your plugin or app define the API provided for
  # with
  #
  # ExternalAPI.register(hash)
  #
  # TODO create ExternalAPI.register do |map| end
  #
  # The API is specified loosely in a hash
  # where an internal key can be mapped to either:
  #
  # a) another string ('translation' of api)
  # b) a proc
  # c) a method being called on the related internal model
  #
  # There is a basic dsl, that could be extended
  #
  # The :query_builder keyword
  # allowes to specify keywords and their mapping
  #
  # The :methods keyword
  # allowes sepecifying available keywords
  #
  # NOTE: it perfectly makes sense, to see
  # the keys for the methods as something,
  # that is to be specified by crabgrass
  #
  #
  # Once an api is registered, you reference it like this:
  #
  # @api = Crabgrass::ExternalApi.for(page_type)
  #
  # TODO write CrabgrassPages - module
  # that allowes returning the api
  # for every page - model .. and so forth
  #
  # Then you have the following accessors:
  #
  #
  #
=begin
     {
      :overlay_page => {
        :model => Geocommons::Overlay,
        :methods => {
          :find => "",
          :create => "",
          :authenticate => ""
        },
        :query_builder => {
          :keywords => {
            :
          },
          :
          "tags" => ""
        }
      }
  }
=end
  #
  class ExternalAPI


    #
    #
    @@registered_apis = HashWithIndifferentAccess.new
    attr :name

    def initialize(name)
      @name = name
    end

    def self.registered_apis
      @@registered_apis
    end

    def self.for(name)
      registered?(name)? new(name) : raise(APINotDefined, "the api #{name.inspect} is not specified")
    end

    def self.registered?(name)
      registered_apis.keys.include?(name)
    end

    def map_table
      @@registered_apis[name]
    end

    def model
      map_table[:model]
    end

    def get_method(method)
      map_table[:methods][method]
    end

    def key_value_separator
      query_builder[:key_value_separator] || "="
    end

    def argument_separator
      query_builder[:argument_separator] || "&"
    end

    def query_builder
       map_table[:query_builder]
    end

    # calls the mapped method
    def call(method_name, args)
      # model.method(get_method(method_name.to_sym).to_sym).call(args)
      model.method(get_method(method_name.to_sym).to_sym).call(args) # FIXME
    end

    #
    #
    # Call this method in your api specification
    #
    #
    def self.register(page_type, hash)
      @@registered_apis[page_type] = hash
    end

    # loads the api spec from yml
    #
    # OPTIONS:
    #
    # :remote => true   # loads the .yml from a external source
    # :auth => "authkey" # pass an auth key to load the apispec
    # TODO enable authentication
    def self.load(name, file_locator, options={:remote => false})


      if options[:remote]
        file = open(file_locator)
      else
        file = File.read(file_locator)
      end
      self.register(YAML.load(file).to_hash[name])
    end


    def self.clear!
      @@registered_apis = { }
    end


    class APINotDefined < Exception
    end

  end
end
