
self.load_once = false if RAILS_ENV =~ /development/
#self.override_views = true

Dispatcher.to_prepare do
  User.send(:include, Crabgrass::UserCredentials)
  User.send(:include, Crabgrass::GeocommonsAuthentication)

  # TODO move this to geocommons.yml
  # -- really? why would I? --wr, 9/30/10
  Crabgrass::ExternalAPI.register('overlay',
                                  { :model => Geocommons::Overlay,
                                    :methods => {
                                      :find => "find",
                                      :paginate => "paginate"
                                    },
                                    :query_builder => {
                                      :keywords => {
                                        "text" => "",
                                        "tag" => "tag"
                                      },
                                      :argument_separator => " ",
                                      :key_value_separator => ":"
                                    }
                                  })

  # TODO move this to geocommons.yml
  Crabgrass::ExternalAPI.register('map',
                                  { :model => Geocommons::Map,
                                    :methods =>
                                    { :find => "find",
                                      :paginate => "paginate"},
                                    :query_builder => {
                                      :keywords => {
                                        "text" => "",
                                        "tag" => "tag"
                                      },
                                      :argument_separator => " ",
                                      :key_value_separator => ":"
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
