Rails.application.routes.draw do
  authenticate :user, lambda {|u| u.role.try(:name) == 'Administrator' } do
    mount Resque::Server.new, at: "/resque", as: :resque
  end
  resources :manifestations
  resources :items
  resources :picture_files
  resources :agents
  resources :manifestation_relationships
  resources :agent_relationships
  resources :resource_import_files
  resources :resource_import_results, only: [:index, :show, :destroy]
  resources :resource_export_files
  resources :resource_export_results, only: [:index, :show, :destroy]
  resources :agent_import_files
  resources :agent_import_results, only: [:index, :show, :destroy]
  resources :series_statements
  resources :series_statement_merges
  resources :series_statement_merge_lists
  resources :agent_merges
  resources :agent_merge_lists
  resources :import_requests

  constraints format: :html do
    resources :produces
    resources :realizes
    resources :creates
    resources :owns
    resources :manifestation_relationship_types
    resources :agent_relationship_types
    resources :agent_types
    resources :produce_types
    resources :realize_types
    resources :create_types
    resources :languages
    resources :countries
    resources :licenses
    resources :form_of_works
    resources :medium_of_performances
    resources :identifier_types
    resources :budget_types
    resources :bookstores
    resources :manifestation_custom_properties
    resources :item_custom_properties
    resources :search_engines
    resources :frequencies
    resources :user_groups
    resources :roles
  end

  resources :carrier_types
  resources :content_types
  resources :donates
  resources :libraries
  resources :shelves
  resources :accepts
  resources :withdraws
  resources :subscribes
  resources :subscriptions
  resources :user_import_files
  resources :user_import_results, only: [:index, :show, :destroy]
  resources :user_export_files
  resources :library_groups, except: [:new, :create, :destroy]
  resources :profiles do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end
  resource :my_account

  resources :iiif_presentations, only: :show, defaults: { format: :html }

  resources :subjects
  constraints format: :html do
    resources :subject_heading_types
    resources :subject_types
    resources :classification_types
  end
  resources :classifications

  resources :checkouts
  resources :checkouts, only: :index do
    put :remove_all, on: :collection
  end
  resources :checkins
  resources :reserves
  resources :user_checkout_stats
  resources :user_reserve_stats
  resources :manifestation_checkout_stats
  resources :manifestation_reserve_stats

  constraints format: :html do
    resources :circulation_statuses
    resources :use_restrictions
    resources :carrier_type_has_checkout_types
    resources :user_group_has_checkout_types
    resources :item_has_use_restrictions
    resources :checkout_types
  end

  resources :checked_items
  resources :baskets

  constraints format: :html do
    resources :event_categories
  end
  resources :events
  resources :event_import_files
  resources :event_import_results, only: [:index, :show, :destroy]
  resources :event_export_files
  resources :participates

  resources :messages do
    collection do
      post :destroy_selected
    end
  end

  constraints format: :html do
    resources :request_status_types, only: [:index, :show, :edit, :update]
    resources :request_types, only: [:index, :show, :edit, :update]
    resources :barcodes, only: :new
  end

  resources :inventories
  resources :inventory_files

  resources :ndl_books, only: [:index, :create]

  resources :nii_types
  resources :cinii_books, only: [:index, :create]

  resources :loc_search, only: [:index, :create]

  resources :bookmarks
  resources :tags
  resources :bookmark_stats

  resources :news_posts
  resources :news_feeds

  devise_for :users

  get '/page/about' => 'page#about'
  get '/page/configuration' => 'page#configuration'
  get '/page/advanced_search' => 'page#advanced_search'
  get '/page/export' => 'page#export'
  get '/page/import' => 'page#import'
  get '/page/opensearch' => 'page#opensearch'
  get '/page/statistics' => 'page#statistics'
  get '/page/system_information' => 'page#system_information'
  get '/page/routing_error' => 'page#routing_error'
  match 'oai', to: "oai#index", via: [:get, :post]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => "page#index"
end
