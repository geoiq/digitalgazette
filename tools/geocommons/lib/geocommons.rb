require 'net/http'
require 'json'

# FIXME this sucks in the unit tests!
# unless defined?(GEOCOMMONS_HOST)
#   raise "You need to define GEOCOMMONS_HOST"
# end

      # WillPaginate::Collection.create(page, per_page, total_entries) do |pager|
      #   count_options = options.except(:page, :per_page, :total_entries, :finder)
      #   find_options = count_options.except(:count).update(:offset => pager.offset, :limit => pager.per_page)

      #   args << find_options.symbolize_keys # else we may break something
      #   found = execute(*args, &block)
      #   pager.total_entries = found[:total]
      #   found = found[:docs]
      #   pager.replace found
      # end

require 'external_page'
module Geocommons
  class RestAPI

    def self.find(options={})
      options[:limit] ||= options[:per_page]
      Net::HTTP.start(GEOCOMMONS_HOST) do |http|
        query = options.each_pair.map { |(k, v)| [k, URI.encode(v.to_s)].join('=') }.join('&')
        path = "/finder/searches.json?#{query}"
        request = Net::HTTP::Get.new(path)
        response = http.request(request)
        if response.kind_of?(Net::HTTPOK)
          return JSON.load(response.body)
        else
          raise "Error searching geocommons: #{response.inspect}"
        end
      end
    end


    class Overlay < Crabgrass::ExternalPage
      VALID_ATTRIBUTES = %w(short_classification name can_view can_edit author
                            can_download published icon_path id contributor
                            tags layer_size link description source bbox
                            created overlay_id detail_link)
      VALID_ATTRIBUTES.each do |attribute|
        attr attribute.to_sym, true
      end

      def initialize(params={})
        params.each_pair do |k, v|
          instance_variable_set("@#{k}", v) if VALID_ATTRIBUTES.include?(k)
        end
      end

      def id
        overlay_id
      end
      
      def cover
        if icon
          file = open(icon)
          def file.original_filename
            File.base_name(icon)
          end
          Asset.build(:uploaded_data => file)
        end
      end


      def updated_at
        created.to_datetime
      end

      def created_at
        created.to_datetime
      end

      def updated_by
        contributor ? contributor : author 
      end
      
      def created_by
        author || ""
      end
      
      def icon
        icon_path
      end

      def title
        name && !name.empty? ? name : description.truncate(30)
      end

      def url
        detail_link
      end
      
      class << self
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

        def _find(options={})
          RestAPI.find(options.merge(:model => 'Overlay'))
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

        def pack_entries(result)
          result['entries'].map do |entry|
            new(entry)
          end
        end

      end
    end

  end
end
