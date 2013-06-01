class EnjuLeaf::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju"

  def copy_setup_files
    directory("db/fixtures", "db/fixtures/enju_leaf")
    directory("solr", "solr")
    copy_file("config/application.yml", "config/application.yml")
    copy_file("config/resque.yml", "config/resque.yml")
    copy_file("config/schedule.rb", "config/schedule.rb")
    gsub_file 'config/application.rb', /# config.i18n.default_locale = :de$/,
      "config.i18n.default_locale = :ja"
    gsub_file 'config/application.rb', /# config.time_zone = 'Central Time \(US & Canada\)'$/,
      "config.time_zone = 'Tokyo'"
    gsub_file 'config/schedule.rb', /\/path\/to\/enju_leaf/, Rails.root.to_s
    append_to_file("Rakefile", "require 'resque/tasks'")
    append_to_file("db/seeds.rb", File.open(File.expand_path('../templates', __FILE__) + '/db/seeds.rb').read)
    append_to_file 'config/initializers/inflections.rb',  <<EOS
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'reserve', 'reserves'
end
EOS
    inject_into_file 'config/environments/development.rb',
      " config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n",
      :after => "::Application.configure do\n"
    inject_into_file 'config/environments/production.rb',
      " config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n",
      :after => "::Application.configure do\n"
    generate("devise:install")
    generate("devise", "User")
    generate("enju_biblio:setup")
    generate("enju_library:setup")
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

  mobylette__config do |config|
    config[:skip_xhr_requests] = false
    config[:skip_user_agents] = Setting.enju.skip_mobile_agents.map{|a| a.to_sym}
  end

EOS
    end
    #inject_into_class "app/models/user.rb", User, "  enju_user_model\n"
    inject_into_file "app/helpers/application_helper.rb", :after => /module ApplicationHelper$\n/ do
      <<"EOS"
  include EnjuLeaf::EnjuLeafHelper
  include EnjuBiblio::BiblioHelper if defined?(EnjuBiblio)
  if defined?(EnjuManifestationViewer)
    include EnjuManifestationViewer::BookJacketHelper
    include EnjuManifestationViewer::ManifestationViewerHelper
  end
EOS
    end
    inject_into_file "app/assets/javascripts/application.js", :after => /\/\/= require jquery_ujs$\n/ do
      "//= require enju_leaf\n"
    end
    inject_into_file "app/assets/stylesheets/application.css", :after => / *= require_self$\n/ do
      " *= require enju_leaf\n"
    end
    inject_into_file "config.ru", :after => /require ::File.expand_path\(\'..\/config\/environment\',  __FILE__\)$\n/ do
      <<"EOS"
require 'rack/protection'
use Rack::Protection, :except => [:escaped_params, :json_csrf, :http_origin, :session_hijacking, :remote_token]
EOS
    end
    generate("sunspot_rails:install")
    remove_file "public/index.html"
    remove_file "app/views/layouts/application.html.erb"
  end
end
