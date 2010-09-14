# Include hook code here



self.load_once = false if RAILS_ENV =~ /development/
self.override_views = true

require 'digital_gazette/page_extension'
require 'digital_gazette/better_configuration'
require 'digital_gazette/stated_ui'

Dispatcher.to_prepare do
  # Add "preferred" keyword to PathFinder.
  #
  # FIXME: PathFinder::ParsedPath::PATH_KEYWORDS is frozen at definition
  #        time. This is a quick hack to add a keyword. This should be
  #        made more easy through the PathFinder API.
  new_path_keywords = PathFinder::ParsedPath::PATH_KEYWORDS.dup
  new_path_keywords['preferred'] = 1
  PathFinder::ParsedPath::PATH_KEYWORDS = new_path_keywords.freeze


  # Extend various classes.
  # (extensions reside in lib/digital_gazette/*_extension.rb)

  PathFinder::ParsedPath.send(:include, ::DigitalGazette::PathFinderParsedPathExtension)
  ControllerExtension::WikiPopup.send(:include, ::DigitalGazette::ControllerExtensionWikiPopupExtension)

  # controllers
  Kernel.load(File.join(Rails.root, 'app', 'controllers', 'application.rb'))
  ApplicationController.send(:include, ::DigitalGazette::StatedUI)
  GroupsController.send(:include, ::DigitalGazette::GroupsControllerExtension)
  PagesController.send(:include, ::DigitalGazette::PagesControllerExtension)
  SearchController.send(:include, ::DigitalGazette::SearchControllerExtension)
  WikiController.send(:include, ::DigitalGazette::WikiControllerExtension)

  # helpers
  LayoutHelper.send(:include, ::DigitalGazette::LayoutHelperExtension)
  MenuHelper.send(:include, ::DigitalGazette::MenuHelperExtension)
  SearchHelper.send(:include, ::DigitalGazette::SearchHelperExtension)

  # models
  Page.send(:include, ::DigitalGazette::PageExtension)
  UnauthenticatedUser.send(:include, ::DigitalGazette::UnauthenticatedUserExtension)
  User.send(:include, ::DigitalGazette::UserGroupsExtension)
  User.send(:include, ::DigitalGazette::UserUsersExtension)
end
