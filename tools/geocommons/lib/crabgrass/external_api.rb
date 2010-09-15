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
      map_table[:key_value_separator] || "="
    end

    def argument_separator
      map_table[:argument_separator] || "&"
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

  end
end
