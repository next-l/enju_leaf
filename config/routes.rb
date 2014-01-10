Rails.application.routes.draw do
  resources :user_import_results

  resources :user_import_files

  resource :my_account

  #resources :users do
  #  resource :patron
  #end
  resources :users

  resources :roles, :except => [:new, :create, :destroy]

  resources :user_groups

  resources :local_patrons, :only => :show

  resources :accepts

  resources :baskets do
    resources :accepts, :except => [:edit, :update]
  end

  root :to => "page#index"

  get '/page/about' => 'page#about'
  get '/page/configuration' => 'page#configuration'
  get '/page/advanced_search' => 'page#advanced_search'
  get '/page/add_on' => 'page#add_on'
  get '/page/export' => 'page#export'
  get '/page/import' => 'page#import'
  get '/page/msie_acceralator' => 'page#msie_acceralator'
  get '/page/opensearch' => 'page#opensearch'
  get '/page/statistics' => 'page#statistics'
  get '/page/routing_error' => 'page#routing_error'
end
