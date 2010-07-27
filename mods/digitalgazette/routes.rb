
# Normal RESTful routes even though we really just need #show
map.resources :maps, {:collection => {:all => :get, :upload => :get}}

map.connect '/about/:id', :controller => 'about', :action => 'show'
map.reports '/reports', :controller => 'pages', :action => 'index', :page_type => 'AssetPage'
map.wiki '/wiki', :controller => 'pages', :action => 'index', :page_type => 'WikiPage'
