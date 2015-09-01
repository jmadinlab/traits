Traits::Application.routes.draw do


  get '/observations/count/:model1/:itemid1', to: 'observations#count'
  get '/observations/count/:model1/:itemid1/:model2/:itemid2', to: 'observations#count'

  get '/resources/:id/doi', to: 'resources#doi'

  get '/users/:id/species', to: 'users#species'

  get '/resources/:id/duplicates', to: 'resources#duplicates'
  get '/traits/:id/duplicates', to: 'traits#duplicates', :as => :duplicates_trait
  get '/traits/:id/meta', to: 'traits#meta', :as => :meta_trait
  get '/traits/overview', to: 'traits#overview', :as => :overview_traits
  get '/traits/:id/resources', to: 'traits#resources', :as => :resources_trait
  # match '/meta/:id',     to: 'static_pages#show',    via: 'get', :as => :show_meta

  match '/resources/:id/expunge',     to: 'resources#expunge',    via: 'get', :as => :expunge_resource

  resources :duplicates 

  resources :releases

  # resources :observations do
  #   resources :issues
  # end

  get 'password_resets/new'

  match '/observation_imports/approve', to: 'observation_imports#approve', via: ['get', 'post'] , :as => :observation_imports_approve

  #get '/imports/show', to: 'imports#show', :as => :show_imports
  # match '/imports/approve', to: 'imports#approve', via: ['get', 'post'] , :as => :approve
  match '/imports/:name', to: 'imports#create', :via => :post, :as => :upload
  get '/imports/:name', to: 'imports#new'
  
  match '/search/json_completion', to: 'search#json_completion', via: 'get', as: 'json_completion'
  
  resources :imports
  resources :search 
  resources :synonyms

  
  get '/history', to:'versions#index'
  get '/history/:version_id', to: 'versions#show'
  post '/revert/:version_id', to: 'versions#revert_back'
  # get '/species/:id/resources', to: 'species#show'
  # get '/traits/:id/resources', to: 'traits#show'
  # get '/locations/:id/resources', to: 'locations#show'
  # get '/resources/:id/resources', to: 'resources#show'
  # get '/releases/:id/resources', to: 'releases#show'

  
  get '/resources/status', to: 'resources#status'

  # match '/duplicate/:id',     to: 'static_pages#duplicate',    via: 'get', :as => :duplicate_meta
# get '/meta/:ids', to: 'static_pages#show'

  
  resources :imports

  resources :methodologies
  post '/methodology/:id/trait', to: 'methodologies#remove_trait', :as => :remove_methodology_trait
  resources :methodologies do
    post :export, :on => :collection
  end

  resources :password_resets

  resources :species do
    post :export, :on => :collection
  end

  resources :species do
    resources :traits do
      resources :users
    end
  end

  resources :locations do
    post :export, :on => :collection
  end

  resources :resources do
    post :export, :on => :collection
  end

  
  resources :standards do
    post :export, :on => :collection
  end

  resources :measurements 

  resources :issues

  resources :observation_imports

  resources :observations do  
    resources :issues

      post :update_multiple, :on => :collection
      # get :autocomplete_location_name, :on => :collection
      # get :autocomplete_specie_name, :on => :collection
      # get :autocomplete_resource_author, :on => :collection

      get :update_values, :on => :collection
      get :update_values, :on => :member
      get :update_random, :on => :collection
      get :update_random, :on => :member

  end

  #match ':controller(/:action(/:id))', via: 'get'

  # resources :users do
  #   resources :traits
  # end
  
  resources :traits do

    post :export, :on => :collection
  end

  resources :entities

  resources :users do  
      post :update_multiple, :on => :collection
  end
  
  resources :sessions,      only: [:new, :create, :destroy]


  root to: 'static_pages#home'
  match '/signup',      to: 'users#new',            via: 'get'
  match '/signin',      to: 'sessions#new',         via: 'get'
  match '/signout',     to: 'sessions#destroy',     via: 'delete'

  match '/meta',        to: 'static_pages#meta',    via: 'get'
  match '/release',        to: 'static_pages#release',    via: 'get'
  match '/uploads',        to: 'static_pages#uploads',    via: 'get'

  match '/procedures',  to: 'static_pages#procedures',   via: 'get'
  match '/editors',     to: 'static_pages#editors',   via: 'get'
  match '/contributors', to: 'static_pages#contributors',   via: 'get'
  match '/download',    to: 'static_pages#download',   via: 'get'
  match '/bulk_import', to: 'static_pages#bulk_import',   via: 'get'
  match '/documentation',    to: 'static_pages#documentation',   via: 'get'

  match '/export_specie_trait', to: 'static_pages#export_specie_trait',   via: 'get'
  match '/export_location_trait', to: 'static_pages#export_location_trait',   via: 'get'
  match '/export_ready_trait', to: 'static_pages#export_ready_trait',   via: 'get'
  match '/export_ready_resources', to: 'static_pages#export_ready_resources',   via: 'get'
  match '/export_ready', to: 'static_pages#export_ready',   via: 'get'

  match '/doi_new',    to: 'resources#doi_new',   via: 'get'


  # dynamic pull-down for trait select
  # match '/update_values', to: 'measurements#update_values', via: 'get'
  

end
