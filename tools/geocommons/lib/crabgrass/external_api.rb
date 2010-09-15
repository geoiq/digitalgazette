module Crabgrass
  class ExternalAPI

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
    #
    @@registered_apis = {}
    attr :name

    def initialize(name)
      @name = name
    end

    def self.for(page_type)
      return new(page_type)
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
      query_builder || "="
    end

    def argument_separator
      query_builder || "&"
    end

    def query_builder
      map_table[:query_builder]
    end

    # calls the mapped method
    def call(method_name, *args)
      model.methods(get_method.to_sym).call(args)
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
        require 'rubygems'
        require 'open-uri'
        file = open(file_locator)
      else
        file = File.read(file_locator)
      end
      self.register(YAML.load(file).to_hash[name])
    end
  end
end
