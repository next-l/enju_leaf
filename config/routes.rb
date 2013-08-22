EnjuLeaf::Application.routes.draw do
  resources :warekis
  resources :user_request_logs
  resources :enju_terminals

  resources :numberings
  resources :departments
  resources :classmarks
  resources :user_statuses
  resources :sheets

  # TODO
  resources :create_types
  resources :realize_types
  resources :produce_types

  devise_for :users, :path => 'accounts'

  resource :my_account

  resources :reminder_lists do
    post :reminder_letter, :on => :collection
    post :reminder_postal_card, :on => :collection
    post :output_reminder_letter, :on => :collection
    post :output_reminder_postal_card, :on => :collection
    get :download_file, :on => :collection
    post :send_reminder, :on => :collection
  end

  resources :series_has_manifestations
  resources :series_statement_merges

  resources :series_statement_merge_lists do
    resources :series_statements
    resources :series_statement_merges
  end

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
    resources :work_has_subjects
    resources :manifestation_relationships
    resources :manifestations
    resources :series_statements
    resources :series_has_manifestations
    resources :reserves
    post :output_show, :on => :member
    get :output_pdf, :on => :member
    post :output_excelx, :on => :collection
    get 'nacsis/:ncid', :on => :collection, :to => 'manifestations#show_nacsis'
  end

  resources :patrons do
    resources :works, :controller => 'manifestations'
    resources :expressions, :controller => 'manifestations'
    resources :manifestations
    resources :items
    resources :picture_files
    resources :patrons
    resources :patron_merges
    resources :patron_merge_lists
    resources :patron_relationships
    resources :creates
    resources :realizes
    resources :produces
  end

  resources :creators, :controller => 'patrons' do
    resources :manifestations do
      post :output_excelx, :on => :collection
    end
  end

  resources :contributors, :controller => 'patrons' do
    resources :manifestations do
      post :output_excelx, :on => :collection
    end
  end

  resources :publishers, :controller => 'patrons' do
    resources :manifestations do
      post :output_excelx, :on => :collection
    end
  end

  resources :works, :controller => 'manifestations' do
    resources :patrons
    resources :creates
    resources :subjects
    resources :work_has_subjects
    resources :expressions, :controller => 'manifestations'
    resources :manifestation_relationships
    resources :manifestations
  end

  resources :expressions, :controller => 'manifestations' do
    resources :patrons
    resources :realizes
    resources :manifestations
    resources :manifestation_relationships
  end

  resources :manifestations do
    resources :produces
    resources :patrons
    resources :items
    resources :picture_files
    resources :expressions, :controller => 'manifestations'
    resources :manifestation_relationships
    resources :manifestations
    resources :exemplifies
    post :output_excelx, :on => :collection
  end

  resources :users do
    get :search_family, :on => :collection
    get :search_family, :on => :member
    get :get_family_info, :on => :collection
    get :get_family_info, :on => :member
    get :get_user_info, :on => :collection
    get :get_user_info, :on => :member
    get :get_user_rent, :on => :member
    get :get_user_rent, :on => :collection
    post :output_password, :on => :member
    resources :answers
    resources :baskets do
      resources :checked_items
      resources :checkins
    end
    resources :checkouts
    resources :questions do
      resources :answers
    end
    resources :reserves
    resources :purchase_requests
    resources :questions
    resource :patron
    resource :family
    resource :family_user
    get :edit_user_number, :on => :member
    post :update_user_number, :on => :member
  end

  resources :loss_items
  resources :answers
  resources :imported_objects
  resources :nii_types
  resources :user_checkout_stats
  resources :user_reserve_stats
  resources :manifestation_checkout_stats
  resources :manifestation_reserve_stats
  resources :manifestation_relationship_types
  #resources :manifestation_exstats
  match '/manifestation_exstats/bestreader' => 'manifestation_exstats#bestreader'
  match '/manifestation_exstats/bestrequest' => 'manifestation_exstats#bestrequest'

  resources :patron_relationship_types
  resources :licenses
  resources :medium_of_performances
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
    resources :patron_merges
  end
  resources :patron_merges
  resources :donates
  resources :subscriptions do
    resources :manifestations
  end
  resources :subscribes
  resources :picture_files
  resources :series_statements do
    resources :manifestations do
      post :output_excelx, :on => :collection
    end
    resources :series_has_manifestations
    resources :series_statement_relationships
  end
  resources :series_statement_relationships
  resources :barcodes
  resources :barcode_lists do
    match 'print', :to => 'barcode_lists#print'
    match 'create_pdf', :to => 'barcode_lists#create_pdf'
    get :show_pdf, :on => :collection
    post :exec_print, :on => :collection
  end
  resources :message_requests, :except => [:new, :create]
  resources :message_templates
  resources :carrier_type_has_checkout_types
  resources :user_group_has_checkout_types
  resources :checkout_types do
    resources :user_group_has_checkout_types
  end
  resources :accept_types
  resources :search_histories, :only => [:index, :show, :destroy]

  resources :order_lists do
    resource :order
    resources :purchase_requests
  end
  resources :orders

  resources :inter_library_loans do
    post :export_loan_lists, :on => :collection
    post :get_loan_lists, :on => :collection
    post :pickup, :on => :collection
    post :pickup_item, :on => :collection
    post :accept, :on => :collection
    get :accept_item, :on => :collection
    get :download_file, :on => :collection
    post :output, :on => :member
  end

  resources :baskets do
    resources :checked_items
  end

  match '/resource_import_textfiles/adapters/:name' => 'resource_import_textfiles#inherent_view'
  resources :resource_import_textfiles do
    get :import_request, :on => :collection
    post :upload, :on => :collection
    resources :resource_import_textresults, :only => [:index, :show, :destroy]
  end

  resources :resource_import_files do
    get :import_request, :on => :collection
    resources :resource_import_results, :only => [:index, :show, :destroy]
  end

  resources :patron_import_files do
    get :import_request, :on => :collection
    resources :patron_import_results, :only => [:index, :show, :destroy]
  end

  resources :patron_import_results, :only => [:index, :show, :destroy]
  resources :resource_import_results, :only => [:index, :show, :destroy]

  resources :questions do
    resources :answers
  end

  resources :purchase_requests do
    resource :order
    get :accept, :on => :member
    get :reject, :on => :member
    get :do_order, :on => :member
  end

  resources :patron_relationships

  resources :bookstores do
    get :search_bookstores, :on => :collection
    resources :order_lists
  end
  resources :areas

  resources :user_has_roles, :only => [:index, :show]

  resources :roles, :except => [:new, :create]

  resources :messages do
    collection do
      post :destroy_selected
    end
  end

  resources :library_groups, :except => [:new, :create, :destroy]

  resources :classifications do
    resources :subject_has_classifications
  end

  resources :classification_types do
    resource :classifications
  end

  resources :search_engines

  resources :reserves do
    post :output, :on => :member
    get :output_pdf, :on => :member
    get :retain, :on => :collection
    post :retain_item, :on => :collection
    post :informed, :on => :member
  end

  resources :subject_types

  resources :work_has_subjects

  resources :subjects do
    resources :works, :controller => 'manifestations'
    resources :subject_heading_types
    resources :subject_has_classifications
    resources :work_has_subjects
    resources :classifications
  end

  resources :content_types

  resources :carrier_types

  resources :retention_periods

  resources :remove_reasons

  resources :manifestation_types

  resources :import_requests

  resources :user_groups do
    resources :user_group_has_checkout_types
  end

  resources :shelves do
    resources :picture_files
    post :output, :on => :collection
  end

  resources :libraries do
    resources :shelves
  end

  resources :checkins
  resources :checked_items

  resources :checkouts do
    collection do
      post 'output'
      get 'extend'
      post 'extend_checkout'
    end
  end

  resources :countries

  resources :languages

  resources :manifestation_relationships

  resources :items do
    resources :binding_items
    resources :checked_items
    resources :inter_library_loans
    resources :item_has_use_restrictions
    resources :lending_policies
    resources :patrons
    resources :owns
    resource :exemplify
    get :remove, :on => :member
    get :restore, :on => :member
    get :numbering, :on => :collection
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
  resources :families do
    collection do
      post 'search_user'
    end
    resources :users
    resources :family_users
  end
  resources :family_users

  resources :budgets
  resources :budget_types
  resources :terms do
    get :get_term, :on => :collection
  end
  resources :budget_and_results_managements

  resources :statistic_reports do
    post :get_monthly_report, :on => :collection
    post :get_daily_report, :on => :collection
    post :get_timezone_report, :on => :collection
    post :get_day_report, :on => :collection
    post :get_age_report, :on => :collection
    post :get_items_report, :on => :collection
    post :get_inout_items_report, :on => :collection
    post :get_loans_report, :on => :collection
    post :get_groups_report, :on => :collection
    post :get_departments_report, :on => :collection
  end

  resources :ndl_statistics do
    post :get_ndl_report, :on => :collection
  end

  resources :print_labels do
    post :get_user_label, :on => :collection
    post 'search_user', :on => :collection
  end

  resources :export_item_lists do
    get :get_list_size, :on => :collection
  end

  resources :export_item_registers do
    get :get_list_size, :on => :collection
  end
 
  resources :library_reports do
    get :daily_report, :on => :collection
    get :monthly_report, :on => :collection
  end

  resources :expenses do
    get :export_report, :on => :collection
    get :get_list_size, :on => :collection
    get :download_file, :on => :collection
  end

  resources :access_logs
  resources :keyword_counts

  resources :bookbindings do
    resources :binding_items
    get :bind_undo, :on => :collection
    get :add_binding_item, :on => :collection
  end
  resources :binding_items
  match '/bookbindings/:bookbinder_id/manifestations' => 'manifestations#index'
  match '/bookbindings/:bookbinder_id/manifestations/output_excelx' => 'manifestations#output_excelx'
  resources :checkout_histories

  resources :copy_requests

  resources :checkoutlists
  resources :nacsis_user_requests

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
  match '/isbn/:isbn' => 'manifestations#show'
  # match ':controller(/:action(/:id(.:format)))'
  match '/page/about' => 'page#about'
  match '/page/configuration' => 'page#configuration'
  match '/page/advanced_search' => 'page#advanced_search'
  match '/page/add_on' => 'page#add_on'
  match '/page/export' => 'page#export'
  match '/page/import' => 'page#import'
  match '/page/msie_acceralator' => 'page#msie_acceralator'
  match '/page/opensearch' => 'page#opensearch'
  match '/page/exstatistics' => 'page#exstatistics'
  match '/page/routing_error' => 'page#routing_error'
  match '/page/extensions' => 'page#extensions'
  match '/page/budgets' => 'page#budgets'

  # for opac begin
  match '/opac/signed_in' => 'opac#signed_in'
  match '/opac/search' => 'opac#search'
  #devise_for :users, :path => 'opac_accounts', :options => {:opac => true}
  scope "opac", :path => "opac", :as => "opac" do
    #devise_for :users, :path => 'accounts', :options => {:opac => true}
    resources :manifestations, :opac => true do
      post :output_show, :on => :member
    end
    resources :users do
      resources :reserves, :opac => true
      resources :checkouts, :opac => true
    end
    resources :events, :opac => true
    match '/manifestation_exstats/bestreader' => 'manifestation_exstats#bestreader', :opac => true
    match '/manifestation_exstats/bestrequest' => 'manifestation_exstats#bestrequest', :opac => true
  end
  devise_scope :user do
    match '/opac' => 'opac#index'
  end
  # for opac end

  match '/batch_checkin' => 'checkins#batchexec' , :via => :post
  match '/batch_checkout' => 'checkouts#batchexec' , :via => :post

  match '/reservelists' => 'reservelists#index'
  match '/unablelist' => 'unablelist#index'
  match '/retained_manifestations' => 'retained_manifestations#index'
  match '/retained_manifestations/informed' => 'retained_manifestations#informed'
  match '/system_configurations' => 'system_configurations#index'
  match '/system_configurations/update' => 'system_configurations#update'
  # http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'page#routing_error' unless Rails.application.config.consider_all_requests_local
end
