# extensions for geocommons based page classes to provide convenient +find+ methods.
module Geocommons::FindMethods
  def find(options_or_id)
    if options_or_id.kind_of?(Hash)
      pack_entries(_find(options_or_id))
    else
      pack_entry(_get(options_or_id))
    end
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
    options = options.merge(default_find_options)
    Geocommons::RestAPI.find(@service, options)
  end

  def _get(id)
    raise "You need to set the geocommons_service in #{self.name}" unless @service
    Geocommons::RestAPI.get(@service, "/#{@model.underscore.pluralize}/#{id}.json")
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
    # log_debug { "Unpacking Result: #{result.inspect}" }
    result['entries'].map do |entry|
      pack_entry(entry)
    end
  rescue => exc
    Rails.logger.fatal(result.inspect)
    Rails.logger.fatal("#{exc.class}: #{exc.message}")
    exc.backtrace.each do |line|
      Rails.logger.fatal(line)
    end
    raise "Failed to unpack the result I just dumped to Rails.logger (along with trace)!"
  end

  def pack_entry(entry)
    new(entry)
  end

  def log_debug(msg=nil, &block)
    Rails.logger.debug do
      "[Geocommons::FindMethods] #{msg || block.call}"
    end
  end
end
