  #
  # NOTE this functionality is good for letting mods add
  #      arguments to PathFinder
  #
  # TODO find a good place for it in the core
  #
  # NOTE this is the only way to do this? ignore warnings
  # TODO think about making PATH_KEYWORDS unfrozen in core
  new_path_keywords = PathFinder::ParsedPath::PATH_KEYWORDS.dup
  new_path_keywords['preferred'] = 1
  PathFinder::ParsedPath::PATH_KEYWORDS = new_path_keywords.freeze
    #
  # Configuration over convention :)
  # NOTE this will help us to make this behaviour easier enabled
  # and configured in mods / sites TODO put it into Conf.


  PATHS_FOR_BOXES =
    { :most_viewed => [["most_viewed"],["limit",5]],
      :recent => [["limit",5],["ascending","created_at"]]}.freeze

  HEADERS_FOR_PAGE_TYPES = {
    "wiki" => true,
    "asset" => true,
  }

  # TODO move all this into Conf
  SEARCHABLE_PAGE_TYPES = ["wiki","asset","map","overlay"].freeze

  EXTERNAL_PAGE_TYPES = ["overlay"].freeze

  LEGAL_PARTIALS = ["pages/list","overlays/list","pages/box"].freeze

  PAGE_TYPE_PARTIALS = {
    "wiki" => "pages/list",
    "asset" => "pages/list",
    "map" => "pages/list",
    "overlay" => "overlays/list"
  }.freeze

  BOX_PARTIALS = {
    "recent" => "pages/box",
    "most_viewed" => "pages/box"
  }.freeze
