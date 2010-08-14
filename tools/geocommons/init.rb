# Include hook code here

self.load_once = false if RAILS_ENV =~ /development/
#self.override_views = true


PageClassRegistrar.add(
  'MapPage',
  :controller => 'maps',
  :icon => 'page_maps',
  :class_group => 'planning',
  :order => 4
)


# TODO move to mod digitalgazette or tools geocommons
GEOCOMMONS_HOST = "digitalgazette.vm"
GEOCOMMONS_IFRAME = "digitalgazette.vm/maker"
