Rails.application.routes.draw do
  post "/auth/:provider/callback" => "sessions#create"
  get "/auth/failure", to: "sessions#failure"
  get "/auth/:provider" => "sessions#new"

  delete '/logout' => 'sessions#destroy'

  resources :profiles

  resources :user_export_files

  resources :user_import_results, :only => [:index, :show, :destroy]

  resources :user_import_files do
    resources :user_import_results, :only => [:index, :show, :destroy]
  end

  resource :my_account

  resources :roles, :except => [:new, :create, :destroy]

  resources :user_groups

  resources :accepts

  resources :baskets do
    resources :accepts, :except => [:edit, :update]
  end

  resources :sessions, only: [:new, :create, :destroy]

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
  get '/page/system_information' => 'page#system_information'
  get '/page/routing_error' => 'page#routing_error'
end
