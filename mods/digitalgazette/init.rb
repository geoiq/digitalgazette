# Include hook code here



self.load_once = false if RAILS_ENV =~ /development/
self.override_views = true

require 'digital_gazette/page_extension'
require 'digital_gazette/better_configuration'

Dispatcher.to_prepare do
  # Extend various classes.
  # (extensions reside in lib/digital_gazette/*_extension.rb)

  ControllerExtension::WikiPopup.send(:include, ::DigitalGazette::ControllerExtensionWikiPopupExtension)

  # controllers
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
