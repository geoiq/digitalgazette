require 'compass'
# If you have any compass plugins, require them here.
if Compass.respond_to?(:add_project_configuration)
  Compass.add_project_configuration(File.join(RAILS_ROOT, "config", "compass.config"))
else
  Compass.configuration.parse(File.join(RAILS_ROOT, "config", "compass.config"))
end
Compass.configuration.environment = RAILS_ENV.to_sym
Compass.configure_sass_plugin!
