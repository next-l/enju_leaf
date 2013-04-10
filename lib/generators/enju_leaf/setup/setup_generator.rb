#class EnjuLeaf::SetupGenerator < Rails::Generators::NamedBase
class EnjuLeaf::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju"

  def copy_setup_files
    directory("db/fixtures", "db/fixtures")
    directory("solr", "solr")
    copy_file("config/application.yml", "config/application.yml")
    remove_file "db/seeds.rb"
    copy_file("db/seeds.rb", "db/seeds.rb")
    generate("devise:install")
    generate("devise", "User")
    rake("enju_leaf_engine:install:migrations")
    rake("enju_biblio_engine:install:migrations")
    rake("enju_library_engine:install:migrations")
    gsub_file 'config/routes.rb', /devise_for :users$/, "devise_for :users, :path => 'accounts'"
    gsub_file 'config/initializers/devise.rb', '# config.email_regexp = /\A[^@]+@[^@]+\z/', 'config.email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i'
    gsub_file 'config/initializers/devise.rb', '# config.authentication_keys = [ :email ]', 'config.authentication_keys = [ :username ]'
    gsub_file 'app/models/user.rb', /, :registerable,$/, ', #:registerable,'
    gsub_file 'app/models/user.rb', /, :trackable, :validatable$/, <<EOS
, :trackable, #:validatable, 
    :lockable, :lock_strategy => :none, :unlock_strategy => :none
  enju_leaf_user_model
EOS
    inject_into_class "app/controllers/application_controller.rb", ApplicationController do
      <<"EOS"
  enju_leaf
  enju_biblio
  enju_library
EOS
    end
    #inject_into_class "app/models/user.rb", User, "  enju_user_model\n"
    inject_into_file "app/helpers/application_helper.rb", :after => /module ApplicationHelper$\n/ do
      <<"EOS"
  include EnjuLeaf::EnjuLeafHelper
  include EnjuBiblio::BiblioHelper if defined?(EnjuBiblio)
  include EnjuBookJacket::BookJacketHelper if defined?(EnjuBookJacket)
  include EnjuManifestationViewer::ManifestationViewerHelper if defined?(EnjuManifestationViewer)
EOS
    end
    inject_into_file "app/assets/javascripts/application.js", :after => /\/\/= require jquery_ujs$\n/ do
      "//= require enju_leaf\n"
    end
    inject_into_file "app/assets/stylesheets/application.css", :after => / *= require_self$\n/ do
      " *= require enju_leaf\n"
    end
    generate("sunspot_rails:install")
    remove_file "public/index.html"
    remove_file "app/views/layouts/application.html.erb"
  end
end
