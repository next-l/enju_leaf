Rails.application.routes.draw do
  devise_for :users, :path => 'accounts'

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

  match '/page/about' => 'page#about'
  match '/page/configuration' => 'page#configuration'
  match '/page/advanced_search' => 'page#advanced_search'
  match '/page/add_on' => 'page#add_on'
  match '/page/export' => 'page#export'
  match '/page/import' => 'page#import'
  match '/page/msie_acceralator' => 'page#msie_acceralator'
  match '/page/opensearch' => 'page#opensearch'
  match '/page/statistics' => 'page#statistics'
  match '/page/routing_error' => 'page#routing_error'
end
