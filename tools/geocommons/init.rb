
self.load_once = false if RAILS_ENV =~ /development/
#self.override_views = true

Dispatcher.to_prepare do
  User.send(:include, Crabgrass::UserCredentials)
  User.send(:include, Crabgrass::GeocommonsAuthentication)


  #
  # mapping of special cases
  order_mapper = lambda{|a|
    ret = { :order => "descending"}
    case a
    when "views_count"
      ret[:sort] = 'relevance'
      return ret
    when "created_at"
      ret[:sort] = 'created_at'
      return ret
    end
    ret
  }

#   cg_key = lambda { |path|
#     path.keys
#   }

#   ext_key = lambda { |args|
#     keys[rand(keys.size)]
#   }

#   { cg_key => ext_key }
#   # /foo/1/bar/2
#   args = cg_key.call('/foo/1/bar/2')
#   { ext_key.call(args) => '???' }
# #----------------------
#   { 'desc' => order_mapper }
#   # /desc/1
#   { order_mapper(1) => 1 }
# #----------------------------------------------
#   keywords = { 'foo' => 'bar' }
#   # path: /foo/x
#   { :bar => 'x' }

  # TODO move this to geocommons.yml
  Crabgrass::ExternalAPI.register('overlay',
                                  { :model => Geocommons::Overlay,
                                    :methods => {
                                      :find => "find",
                                      :paginate => "paginate"
                                    },
                                    :query_builder => {
                                      :defaults => { 'limit' => 2 },
                                      :keywords => {
                                        'limit' => 'per_page',
                                        "text" => "query",
                                        "tag" => "tag",
                                        "per_page" => "per_page",
                                        "page" => "page",
                                        "descending" => order_mapper
                                      },
                                      :argument_separator => " ",
                                      :key_value_separator => ""
                                    }
                                  })

  # TODO move this to geocommons.yml
  Crabgrass::ExternalAPI.register('map',
                                  { :model => Geocommons::Map,
                                    :methods =>
                                    { :find => "find",
                                      :paginate => "paginate"},
                                    :query_builder => {
                                      :defaults => { 'limit' => 2 },
                                      :keywords => {
                                        'limit' => 'per_page',
                                        "text" => "query",
                                        "tag" => "tag",
                                        "per_page" => "per_page",
                                        "page" => "page",
                                        "descending" => order_mapper
                                      },
                                      :argument_separator => " ",
                                      :key_value_separator => ""
                                    }
                                  }
                                )
  PathFinder::ParsedPath.send(:include, Crabgrass::PathFinderParsedPathExtension) unless PathFinder::ParsedPath.included_modules.include?(Crabgrass::PathFinderParsedPathExtension)
end

  # Add "preferred" keyword to PathFinder.
#
# FIXME: PathFinder::ParsedPath::PATH_KEYWORDS is frozen at definition
#        time. This is a quick hack to add a keyword. This should be
#        made more easy through the PathFinder API.
new_path_keywords = PathFinder::ParsedPath::PATH_KEYWORDS.dup
new_path_keywords['preferred'] = 1
PathFinder::ParsedPath::PATH_KEYWORDS = new_path_keywords.freeze

PathFinder::ParsedPath.send(:include, Crabgrass::PathFinderParsedPathExtension)



# tools don't load helpers automatically
Kernel.load File.join(File.dirname(__FILE__), 'app', 'helpers', 'geocommons_helper.rb')
