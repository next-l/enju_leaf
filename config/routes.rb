Rails.application.routes.draw do
  authenticate :user, lambda {|u| u.role.try(:name) == 'Administrator' } do
    mount Resque::Server.new, at: "/resque", as: :resque
  end
  resources :manifestations
  resources :items
  resources :picture_files
  resources :agents
  resources :agents
  resources :agent_types
  resources :produces
  resources :realizes
  resources :creates
  resources :owns
  resources :produce_types
  resources :realize_types
  resources :create_types
  resources :manifestation_relationships
  resources :manifestation_relationship_types
  resources :agent_relationships
  resources :agent_relationship_types
  resources :resource_import_files
  resources :resource_import_results
  resources :resource_export_files
  resources :resource_export_results
  resources :agent_import_files
  resources :agent_import_results
  resources :licenses
  resources :languages
  resources :countries
  resources :series_statements
  resources :series_statement_merges
  resources :series_statement_merge_lists
  resources :agent_merges
  resources :agent_merge_lists
  resources :manifestation_custom_properties
  resources :item_custom_properties
  resources :import_requests
  resources :carrier_types
  resources :content_types
  resources :form_of_works
  resources :medium_of_performances
  resources :donates
  resources :frequencies
  resources :identifier_types
  resources :libraries
  resources :shelves
  resources :search_engines
  resources :user_groups
  resources :accepts
  resources :withdraws
  resources :bookstores
  resources :budget_types
  resources :subscribes
  resources :subscriptions
  resources :user_import_files
  resources :user_import_results
  resources :user_export_files
  resources :library_groups
  resources :roles
  resources :profiles do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end
  resource :my_account

  resources :subjects
  resources :subject_heading_types
  resources :subject_types
  resources :classifications
  resources :classification_types

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
  resources :lending_policies
  resources :circulation_statuses
  resources :use_restrictions
  resources :carrier_type_has_checkout_types
  resources :user_group_has_checkout_types
  resources :checkout_types
  resources :checked_items
  resources :item_has_use_restrictions
  resources :baskets

  resources :events
  resources :event_categories
  resources :event_import_files
  resources :event_import_results
  resources :event_export_files
  resources :participates

  resources :messages do
    collection do
      post :destroy_selected
    end
  end
  resources :message_templates
  resources :message_requests
  resources :request_status_types
  resources :request_types

  resources :inventories
  resources :inventory_files

  resources :ndl_books

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
  get '/page/add_on' => 'page#add_on'
  get '/page/export' => 'page#export'
  get '/page/import' => 'page#import'
  get '/page/msie_accelerator' => 'page#msie_accelerator'
  get '/page/opensearch' => 'page#opensearch'
  get '/page/statistics' => 'page#statistics'
  get '/page/system_information' => 'page#system_information'
  get '/page/routing_error' => 'page#routing_error'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => "page#index"
end
