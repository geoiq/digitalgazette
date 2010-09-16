map.maps '/maps', :controller => 'pages', :action => 'index', :page_type => "map"
map.map_search '/maps/search/*path', :controller => 'search', :action => 'index', :page_type => 'map'

map.connect '/about/:id', :controller => 'about', :action => 'show'
map.reports '/reports', :controller => 'pages', :action => 'index', :page_type => 'asset'
map.reports_search '/reports/search/*path', :controller => 'search', :action => 'index', :page_type => "asset"
map.wiki '/wiki', :controller => 'pages', :action => 'index', :page_type => 'wiki'

map.wiki_search '/wiki/search/*path', :controller => 'search', :action => 'index', :page_type => "wiki"


# Normal RESTful routes even though we really just need #show
map.resources :maps, {:collection => {:all => :get, :upload => :get}}
