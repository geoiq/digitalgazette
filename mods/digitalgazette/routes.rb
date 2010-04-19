
# Normal RESTful routes even though we really just need #show
map.resources :maps, {:collection => {:all => :get}}

map.connect '/about/:id', :controller => 'about', :action => 'show'
