# Include hook code here

self.load_once = false if RAILS_ENV =~ /development/
self.override_views = true


PageClassRegistrar.add(
  'MapPage',
  :controller => 'maps',
  :icon => 'page_maps',
  :class_group => 'planning',
  :order => 4
)
