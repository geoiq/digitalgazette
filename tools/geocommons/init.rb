# Include hook code here

self.load_once = false if RAILS_ENV =~ /development/
#self.override_views = true

Dispatcher.to_prepare do
  User.send(:include, Crabgrass::UserCredentials)

  # TODO move this to geocommons.yml
  Crabgrass::ExternalAPI.register('overlay',
                                  { :model => Geocommons::Overlay,
                                    :methods => {
                                      :find => "paginate"
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
                                    { :find => "paginate"},
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
end

  # Add "preferred" keyword to PathFinder.
#
# FIXME: PathFinder::ParsedPath::PATH_KEYWORDS is frozen at definition
#        time. This is a quick hack to add a keyword. This should be
#        made more easy through the PathFinder API.
new_path_keywords = PathFinder::ParsedPath::PATH_KEYWORDS.dup
new_path_keywords['preferred'] = 1
PathFinder::ParsedPath::PATH_KEYWORDS = new_path_keywords.freeze

PathFinder::ParsedPath.send(:include, ::Geocommons::PathFinderParsedPathExtension)



# tools don't load helpers automatically
Kernel.load File.join(File.dirname(__FILE__), 'app', 'helpers', 'geocommons_helper.rb')
