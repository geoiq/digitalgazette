# Include hook code here

self.load_once = false if RAILS_ENV =~ /development/
#self.override_views = true

Dispatcher.to_prepare do
  User.send(:include, Crabgrass::UserCredentials)
end

# tools don't load helpers automatically
Kernel.load File.join(File.dirname(__FILE__), 'app', 'helpers', 'geocommons_helper.rb')
