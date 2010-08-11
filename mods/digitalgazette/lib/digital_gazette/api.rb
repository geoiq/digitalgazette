require 'yaml'
module DigitalGazette
  class Api
    attr :name
    def initialize name
      @name = name
      @@api_conf ||= YAML.load(File.read("#{RAILS_ROOT}/mods/digitalgazette/api.yml"))
      @@api_conf[name.to_s].each_pair do |k,v|
        Api.class_eval do
          attr k.to_sym
        end
        instance_variable_set(:"@#{k}",v)
      end
    end
  end
end
