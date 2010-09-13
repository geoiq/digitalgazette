module Geocommons
  class RestAPI

    def self.find(options={})
      unless finder_url = Geocommons.config(:map, :finder)
        raise "No finder configuration. Geocommons config is: #{self.class.config.inspect}"
      end

      options[:limit] ||= options[:per_page]
      # TODO don't use :map here - invent :general and separate by model
      uri = URI.parse(finder_url)
      Net::HTTP.start(uri.host) do |http|
        query = options.each_pair.map { |(k, v)| [k, URI.encode(v.to_s)].join('=') }.join('&')
        path = "/searches.json?#{query}"
        request = Net::HTTP::Get.new(path)
        response = http.request(request)
        if response.kind_of?(Net::HTTPOK)
          return JSON.load(response.body)
        else
          raise "Error searching geocommons: #{response.inspect}"
        end
      end
    end
  end
end
