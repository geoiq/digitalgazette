require 'net/https'

module Geocommons
  class RestAPI
    class << self
      def get(service, path)
        start_connection(uri = service_uri(service)) do |http|
          if (response = http.request(build_request(File.join(uri.path, path)))).kind_of?(Net::HTTPOK)
            return JSON.load(response.body)
          else
            raise "Error getting geocommons: #{response.inspect}"
          end
        end
      end

      # Query the Geocommons search API via GET requests on /searches.json.
      #
      # The given +service+ will be looked up via Geocommons.config to find
      # the right base url.
      #
      # All options will be passed on in the query string, except:
      # * :user - Will be used to perform authentication
      def find(service, options={})
        log_debug("Querying sevice '#{service}' for #{options.inspect}")
        options[:limit] ||= options[:per_page]

        uri = service_uri(service)

        start_connection(uri) do |http|
          response = http.request(build_request(File.join(uri.path || '/', 'searches.json'), options))

          if response.kind_of?(Net::HTTPOK)
            result = JSON.load(response.body)
            log_debug { "Got #{result['totalResults']} results (#{result['itemsPerPage']} per page)." }
            return result
          else
            raise "Error searching geocommons: #{response.inspect}"
          end
        end
      end

      protected

      # build a Net::HTTP::Get request for the given path, with the given options
      # (to be serialized as query string). If options[:user] is given, the request
      # will be authenticated via HTTP Basic Auth.
      def build_request(path, options={})
        user = options.delete(:user)
        request = Net::HTTP::Get.new([path, serialize_options(options)].join('?'))
        add_credentials(user, request) if user
        log_debug { "Requesting #{request.path}" }
        return request
      end

      # serialize given options to a encoded URL query string
      def serialize_options(options)
        options.each_pair.map { |(k, v)|
          [k, URI.encode(v.to_s)].join('=')
        }.join('&')
      end

      # add credentials from the given user to the given
      # request to perform HTTP Basic Authentication.
      def add_credentials(user, request)
        creds = user.credentials_for(:geocommons)
        request.basic_auth(creds[:login], creds[:password])
        log_debug { "Authenticating as #{creds[:login]} with password #{'*' * creds[:password].size}" }
        return request
      end

      def start_connection(uri)
        log_debug("Connecting to #{uri.to_s}...")
        Net::HTTP.start(uri.host, uri.port) do |http|
          http.use_ssl = true if uri.scheme == 'https'
          return yield(http)
        end
      end

      def log_debug(msg=nil, &block)
        Rails.logger.debug do
          "[Geocommons::RestAPI] #{msg || block.call}"
        end
      end

      def service_uri(service)
        URI.parse(Geocommons.config(:map, service))
      end
    end
  end
end
