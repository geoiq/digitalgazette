# extensions for geocommons based page classes to provide convenient +find+ methods.
module Geocommons::FindMethods
  def find(options={})
    pack_entries(_find(options))
  end

  def geocommons_service(service)
    @service = service.to_sym
  end

  def geocommons_model(model)
    @model = model.to_s
  end

  # query Geocommons with the given options. the queried model will
  # be determined by +geocommons_model_name+
  def _find(options={})
    raise "You need to set the geocommons_service in #{self.name}" unless @service
    Geocommons::RestAPI.find(@service, options.merge(default_find_options))
  end

  def default_find_options
    { :model => @model }
  end

  def count(options)
    _find(options)["totalResults"]
  end

  # takes a result hash, as returned by Geocommons::RestAPI and
  # turns it into an array of pages.
  def pack_entries(result)
    log_debug { "Unpacking Result: #{result.inspect}" }
    result['entries'].map do |entry|
      new(entry)
    end
  rescue => exc
    Rails.logger.fatal(result.inspect)
    Rails.logger.fatal("#{exc.class}: #{exc.message}")
    exc.backtrace.each do |line|
      Rails.logger.fatal(line)
    end
    raise "Failed to unpack the result I just dumped to Rails.logger (along with trace)!"
  end

  def log_debug(msg=nil, &block)
    Rails.logger.debug do
      "[Geocommons::FindMethods] #{msg || block.call}"
    end
  end
end
