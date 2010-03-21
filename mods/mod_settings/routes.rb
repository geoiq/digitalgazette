

map.namespace :admin do |admin|
  admin.mod_settings '/mod_settings', :controller => 'mod_settings', :action => 'index'
end
