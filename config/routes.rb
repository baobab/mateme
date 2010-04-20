ActionController::Routing::Routes.draw do |map|
  map.root :controller => "people"
  map.admin  '/admin',  :controller => 'admin', :action => 'index'
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login  '/people/login',  :controller => 'sessions', :action => 'new'
  map.logout '/people/logout', :controller => 'sessions', :action => 'destroy'
  map.location '/location', :controller => 'sessions', :action => 'location'
  map.resource :session
  map.resources :barcodes, :collection => {:label => :get}
  map.resources :encounter_types
  map.connect 'encounters/:action/:encounter_type', :controller => 'encounters'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/'
end
