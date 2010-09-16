class Geocommons::RestAPI
  class << self
    def get(service, path)
      validate_service(service)
      raise "You need to call 'set_fake_get_data' before calling find" unless @fake_get_data
      return @fake_get_data
    end

    def find(service, options={})
      validate_service(service)
      raise "You need to call 'set_fake_find_data' before calling find" unless @fake_find_data
      return @fake_find_data
    end

    def set_fake_find_data(data)
      @fake_find_data = data
    end

    def set_fake_get_data(data)
      @fake_get_data = data
    end

    def clear_fake_data
      @fake_find_data = @fake_get_dat = nil
    end

    private

    def validate_service(service)
      unless (available_services = Geocommons.config(:map))[service]
        raise "Unknown service: #{service.inspect}. Available services: #{available_services.keys.inspect}"
      end
    end
  end
end
