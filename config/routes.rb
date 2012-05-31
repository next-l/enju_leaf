EnjuLeaf::Application.routes.draw do
  devise_for :users, :path => 'accounts'

  resource :my_account

  resources :manifestations do
    resources :patrons
    resources :creators, :controller => 'patrons'
    resources :contributors, :controller => 'patrons'
    resources :publishers, :controller => 'patrons'
    resources :creates
    resources :realizes
    resources :produces
    resources :picture_files
    resources :items
    resources :manifestation_relationships
    resources :manifestations
  end

  resources :patrons do
    resources :works, :controller => 'manifestations'
    resources :expressions, :controller => 'manifestations'
    resources :manifestations
    resources :items
    resources :picture_files
    resources :patrons
    resources :patron_relationships
    resources :creates
    resources :realizes
    resources :produces
  end

  resources :creators, :controller => 'patrons' do
    resources :manifestations
  end

  resources :contributors, :controller => 'patrons' do
    resources :manifestations
  end

  resources :publishers, :controller => 'patrons' do
    resources :manifestations
  end

  #resources :users do
  #  resource :patron
  #end

  resources :medium_of_performances
  resources :extents
  resources :patron_types
  resources :donates
  resources :subscriptions do
    resources :manifestations
  end
  resources :subscribes
  resources :picture_files
  resources :participates

  resources :roles, :except => [:new, :create, :destroy]

  resources :library_groups, :except => [:new, :create, :destroy]

  resources :content_types

  resources :carrier_types

  resources :import_requests

  resources :user_groups

  resources :shelves do
    resources :picture_files
  end

  resources :libraries do
    resources :shelves
  end

  resources :resource_import_files do
    resources :resource_import_results, :only => [:index, :show, :destroy]
  end

  resources :patron_import_files do
    resources :patron_import_results, :only => [:index, :show, :destroy]
  end

  resources :patron_import_results, :only => [:index, :show, :destroy]
  resources :resource_import_results, :only => [:index, :show, :destroy]

  resources :items do
    resources :patrons
    resources :owns
    resource :exemplify
    resources :manifestations, :only => [:index]
  end

  resources :owns
  resources :exemplifies

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
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
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
  #       get 'recent', :on => :collection
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
  # match ':controller(/:action(/:id))(.:format)'
  match '/isbn/:isbn' => 'manifestations#show'
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
  match '/page/routing_error' => 'page#routing_error'
end
