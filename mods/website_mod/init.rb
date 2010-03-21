self.load_once = false

Dispatcher.to_prepare do
  require 'website_mod_listener'
end
