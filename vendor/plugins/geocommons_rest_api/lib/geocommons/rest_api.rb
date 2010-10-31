require 'net/https'

module Geocommons
  class RestAPI
    class << self
      # get a specific response entity based on the given path.
      def get(service, path)
        # NOTE you can disable the connection globally for tests without internet connection
        if ! (defined?(EXTERNAL_API_TEST_MODE) && EXTERNAL_API_TEST_MODE == :skip)
          start_connection(uri = service_uri(service)) do |http|
            if (response = http.request(build_request(File.join(uri.path, path)))).kind_of?(Net::HTTPOK)
              return JSON.load(response.body)
            elsif response.kind_of?(Net::HTTPFound)
              raise "Error getting geocommons path #{path}: Got redirected to: #{response['Location']}"
            else
              raise "Error getting geocommons path #{path}: #{response.inspect}"
            end
          end
        else
          # Hack for test mode: always return empty result.
          JSON.load({ :totalResults => 0, :entries => []})
        end
      end

      # Query the Geocommons search API via GET requests on /searches.json.
      #
      # The given +service+ will be looked up via Geocommons.config to find
      # the right base url.
      #
      # All options will be passed on in the query string, except:
      # * :user - Will be used to perform authentication
      # * :cookie - Will be attached to the request (use start_session to obtain a session cookie)
      def find(service, options={})
        log_debug("Querying service '#{service}' for #{options.inspect}")
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

      # Authenticate against geocommons. Returns the session cookie if successful.
      def start_session(service, login, password)
        log_debug("Starting session at service #{service} for login #{login}")
        uri = service_uri(service)
        start_connection(uri) do |http|
          request = Net::HTTP::Post.new(File.join(uri.path || '/', 'sessions.json'))
          request.body = serialize_options('session[login]' => login, 'session[password]' => password)
          response = http.request(request)
          case response.code.to_i
          when 201 # Created
            return response['Set-Cookie']
          when 401 # Authorization required
            return false
          else # unknown
            log_error("Received unknown response code #{response.code} when trying to authenticate against geocommons")
            return false
          end
          return response
        end
      end

      protected

      # build a Net::HTTP::Get request for the given path, with the given options
      # (to be serialized as query string). If options[:user] is given, the request
      # will be authenticated via HTTP Basic Auth.
      # If options[:cookie] is given, it will be attached to the request as well.
      def build_request(path, options={})
        user = options.delete(:user)
        cookie = options.delete(:cookie)
        request = Net::HTTP::Get.new([path, serialize_options(options)].join('?'))
        request['Cookie'] = cookie
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
      rescue Net::HTTP::Unauthorized => exc
        raise PermissionDenied
      end

      def service_uri(service)
        URI.parse(Geocommons.config(:map, service))
      end

      def log_debug(msg=nil, &block)
        Rails.logger.debug do
          "[Geocommons::RestAPI] #{msg || block.call}"
        end
      end

      def log_error(msg=nil, &block)
        Rails.logger.error do
          "[Geocommons::RestAPI] #{msg || block.call}"
        end
      end
    end
  end
end
