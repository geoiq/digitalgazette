# Handles pagination aspects of Geocommons::BasePage based on Geocommons::FindMethods
module Geocommons::Pagination
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

  def paginate_by_tag(tags, options = {})
    condition = options[:condition] ? options.delete(:condition) : "or"
    condition = " "+condition+" "
    separator = "tag:"
    query = "tag:" << tags.to_a.join(condition+separator)
    paginate(options.merge(:query => query))
  end
end
