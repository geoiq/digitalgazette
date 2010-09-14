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

if File.exist?(config_path = File.join(Rails.root, 'config', 'geocommons.yml'))
  Dispatcher.to_prepare do
    Geocommons.config = YAML.load_file(config_path)
  end
end

# tools don't load helpers automatically
Kernel.load File.join(File.dirname(__FILE__), 'app', 'helpers', 'geocommons_helper.rb')
