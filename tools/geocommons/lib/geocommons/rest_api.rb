module Geocommons
  class RestAPI
    class << self
      # Query the Geocommons Finder API via GET requests on /searches.json.
      # All options will be passed on in the query string, except:
      # * :user - Will be used to perform authentication
      def find(options={})

        options[:limit] ||= options[:per_page]

        start_connection do |http|
          response = http.request(build_request('/searches.json', options))

          if response.kind_of?(Net::HTTPOK)
            return JSON.load(response.body)
          else
            raise "Error searching geocommons: #{response.inspect}"
          end
        end
      end

      protected

      # build a Net::HTTP::Get request for the given path, with the given options
      # (to be serialized as query string). If options[:user] is given, the request
      # will be authenticated via HTTP Basic Auth.
      def build_request(path, options)
        user = options.delete(:user)
        request = Net::HTTP::Get.new([path, serialize_options(options)].join('?'))
        add_credentials(user, request) if user
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
        login, password = user.get_credentials(:geocommons)
        request.basic_auth(login, password)
        return request
      end

      # Start a HTTP connection to the finder host as
      # specified in Geocommons.config. Yields the
      # Net::HTTP connection.
      def start_connection
        unless finder_url = Geocommons.config(:map, :finder)
          raise "No finder configuration. Geocommons config is: #{self.class.config.inspect}"
        end

        uri = URI.parse(finder_url)
        Net::HTTP.start(uri.host) do |http|
          yield(http)
        end
      end
    end
  end
end
