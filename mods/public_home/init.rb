
Dispatcher.to_prepare do
  ModSetting.register(:mod => 'public_home',
                      :name => :public_home,
                      :type => :boolean,
                      :label => "Enable Public Site Home",
                      :description => "This mod uses the site home as a first landing point before logging in. This way the sites content is also accessible for people who do not have a login yet.")
end
