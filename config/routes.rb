ActionController::Routing::Routes.draw do |map|
  map.root :controller => "people"
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.resource :session
  map.connect 'encounters/:action/:encounter_type', :controller => 'encounters'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/'
end
