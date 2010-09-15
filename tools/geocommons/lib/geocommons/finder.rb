module Geocommons::Finder
  def paginate_by_tag(tags, options = {})

    condition = options[:condition] ? options.delete(:condition) : "or"
    condition = " "+condition+" "
    separator = "tag:"
    query = "tag:" << tags.to_a.join(condition+separator)
    paginate(options.merge(:query => query))
  end

  def find(options={})
    pack_entries(_find(options))
  end

  # query Geocommons with the given options. the queried model will
  # be determined by +geocommons_model_name+
  def _find(options={})
    Geocommons::RestAPI.find(options.merge(:model => geocommons_model_name))
  end

  # override this if your class name doesn't match the name of the
  # queried geocommons model
  def geocommons_model_name
    self.class.name
  end

  # get a list of overlays. useful options:
  # * +page+ - number (>= 1), page to use. default: 1
  # * +per_page+ - number (>= 1), results to return per page. default: 10
  # * +query+ - query to send, such as tag:foobar
  def paginate(options={})
    page = options[:page] || 1
    per_page = options[:per_page] || 2
    WillPaginate::Collection.create(page, per_page, count(options)) do |pager|
      # @options_from_last_find = nil
      count_options = options.except :page, :per_page, :total_entries, :finder
      find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page)
      find_results = pack_entries((_find(options)))
      pager.replace find_results # remove?
      # magic counting for user convenience:
      pager.total_entries = count(options) # remove ?
    end
  end

  def count(options)
    _find(options)["totalResults"]
  end

  # takes a result hash, as returned by Geocommons::RestAPI and
  # turns it into an array of pages.
  def pack_entries(result)
    result['entries'].map do |entry|
      new(entry)
    end
  end
end
