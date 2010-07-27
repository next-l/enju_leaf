EnjuLeaf::Application.routes.draw do |map|
  devise_for :users

  resources :resources do
    resources :patrons
    resources :creators, :controller => 'patrons'
    resources :contributors, :controller => 'patrons'
    resources :publishers, :controller => 'patrons'
    resources :creates
    resources :realizes
    resources :produces
    resources :picture_files
    resources :items
    resources :work_has_subjects
    resources :resource_relationships
    resources :resources
  end

  resources :patrons do
    resources :works, :controller => 'resources'
    resources :expressions, :controller => 'resources'
    resources :manifestations, :controller => 'resources'
    resources :items
    resources :picture_files
    resources :resources
    resources :patrons
    resources :patron_merges
    resources :patron_merge_lists
    resources :patron_relationships
  end

  resources :works, :controller => 'resources' do
    resources :patrons
    resources :creates
    resources :subjects
    resources :work_has_subjects
    resources :expressions, :controller => 'resources'
    resources :resource_relationships
    resources :resources
  end

  resources :expressions, :controller => 'resources' do
    resources :patrons
    resources :realizes
    resources :manifestations, :controller => 'resources'
    resources :resource_relationships
    resources :resources
  end

  resources :manifestations, :controller => 'resources' do
    resources :produces
    resources :patrons
    resources :items
    resources :picture_files
    resources :expressions, :controller => 'resources'
    resources :resource_relationships
    resources :resources
  end

  resources :creators, :controller => 'patrons' do
    resources :resources
  end

  resources :contributors, :controller => 'patrons' do
    resources :resources
  end

  resources :publishers, :controller => 'patrons' do
    resources :resources
  end

  resources :users do
    resources :answers
    resources :baskets do
      resources :checked_items
      resources :checkins
    end
    resources :checkouts
    resources :questions do
      resources :answers
    end
    resources :messages do
      collection do
        post :destroy_selected
      end
    end
    resources :reserves
    resources :bookmarks
    resources :purchase_requests
    resources :questions
    resource :patron
  end

  resources :answers
  resources :imported_objects
  resources :nii_types
  resources :bookmark_stats
  resources :bookmark_stat_has_manifestations
  resources :user_checkout_stats
  resources :user_reserve_stats
  resources :manifestation_checkout_stats
  resources :manifestation_reserve_stats
  resources :resource_relationship_types
  resources :patron_relationship_types
  resources :licenses
  resources :medium_of_performance
  resources :extents
  resources :request_status_types
  resources :request_types
  resources :frequencies
  resources :use_restrictions
  resources :item_has_use_restrictions
  resources :lending_policies
  resources :patron_types
  resources :circulation_statuses
  resources :form_of_works
  resources :subject_has_classifications
  resources :subject_heading_types do
    resources :subjects
  end
  resources :subject_heading_type_has_subjects
  resources :patron_merge_lists do
    resources :patrons
  end
  resources :patron_merges
  resources :inventory_files
  resources :inventories
  resources :donates
  resources :subscriptions do
    resources :resources
  end
  resources :subscribes
  resources :picture_files
  resources :series_statements do
    resources :manifestations, :controller => :resources
  end
  resources :barcodes
  resources :message_requests
  resources :message_templates
  resources :carrier_type_has_checkout_types
  resources :user_group_has_checkout_types
  resources :checkout_types do
    resources :user_group_has_checkout_types
  end
  resources :search_histories

  resources :order_lists do
    resource :order
    resources :purchase_requests
  end
  resources :orders

  resources :inter_library_loans

  resources :baskets do
    resources :checked_items
  end

  resources :resource_import_files

  resources :patron_import_files

  resources :event_import_files

  resources :events do
    resources :picture_files
  end

  resources :participates

  resources :questions

  resources :purchase_requests do
    resources :order
  end

  resources :bookmarks

  resources :tags

  resources :patron_relationships

  resources :bookstores do
    resources :order_lists
  end

  resources :user_has_roles

  resources :roles

  resources :messages

  resources :library_groups

  resources :classifications do
    resources :subject_has_classifications
  end

  resources :classification_types do
    resource :classifications
  end

  resources :search_engines

  resources :reserves

  resources :event_categories

  resources :events

  resources :subject_types

  resources :work_has_subjects

  resources :subjects do
    resources :works
    resources :subject_heading_types
    resources :subject_has_classifications
    resources :work_has_subjects
    resources :classifications
  end

  resources :content_types

  resources :carrier_types

  resources :import_requests

  resources :user_groups do
    resources :user_group_has_checkout_types
  end

  resources :shelves do
    resources :picture_files
  end

  resources :libraries do
    resources :events
    resources :shelves
  end

  resources :checkins
  resources :checked_items

  resources :checkouts

  resources :countries

  resources :languages

  resources :resource_relationships

  resources :items do
    resources :checked_items
    resources :inter_library_loans
    resources :item_has_use_restrictions
    resources :lending_policies
    resources :patrons
  end

  resources :owns
  resources :produces
  resources :realizes
  resources :creates
  resources :exemplifies

  resources :checkout_stat_has_manifestations
  resources :checkout_stat_has_users
  resources :reserve_stat_has_manifestations
  resources :reserve_stat_has_users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "page#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
  match '/isbn/:isbn' => 'resources#show'
  match '/calendar(/:year(/:month))' => 'calendar#index', :as => :calendar, :constraints => {:year => /\d{4}/, :month => /\d{1,2}/}
  match "/calendar/:year/:month/:day" => "calendar#show"
  match '/page/about' => 'page#about'
  match '/page/configuration' => 'page#configuration'
  match '/page/advanced_search' => 'page#advanced_search'
  match '/page/add_on' => 'page#add_on'
  match '/page/export' => 'page#export'
  match '/page/import' => 'page#import'
  match '/page/msie_acceralator' => 'page#msie_acceralator'
  match '/page/opensearch' => 'page#opensearch'
  match '/page/statistics' => 'page#statistics'
end
