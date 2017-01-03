class EnjuLeaf::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju"

  def copy_setup_files
    directory("db/fixtures", "db/fixtures/enju_leaf")
    directory("solr", "example/solr")
    copy_file("Procfile", "Procfile")
    copy_file("config/schedule.rb", "config/schedule.rb")
    copy_file("config/initializers/resque.rb", "config/initializers/resque.rb")
    append_to_file("config/initializers/assets.rb", "Rails.application.config.assets.precompile += %w( *.png *.gif )")
    inject_into_file 'config/application.rb', after: /# config.i18n.default_locale = :de$\n/ do
      <<"EOS"
    config.i18n.available_locales = [:en, :ja]
    config.i18n.enforce_available_locales = true
    config.active_job.queue_adapter = :resque
EOS
    end
    gsub_file 'config/application.rb', /# config.i18n.default_locale = :de$/,
      "config.i18n.default_locale = :ja"
    gsub_file 'config/application.rb', /# config.time_zone = 'Central Time \(US & Canada\)'$/,
      "config.time_zone = 'Tokyo'"
    gsub_file 'config/schedule.rb', /\/path\/to\/enju_leaf/, Rails.root.to_s
    append_to_file("Rakefile", "require 'resque/tasks'\n")
    append_to_file("Rakefile", "require 'resque/scheduler/tasks'")
    append_to_file("db/seeds.rb", File.open(File.expand_path('../templates', __FILE__) + '/db/seeds.rb').read)
    application(nil, env: "development") do
      "config.action_mailer.default_url_options = {host: 'localhost:3000'}\n"
    end
    application(nil, env: "test") do
      "config.action_mailer.default_url_options = {host: 'localhost:3000'}\n"
    end
    application(nil, env: "production") do
      "config.action_mailer.default_url_options = {host: 'localhost:3000'}\n"
    end
    generate("devise:install")
    generate("devise", "User")
    gsub_file 'app/models/user.rb', /, :registerable,$/, ', #:registerable,'
    gsub_file 'app/models/user.rb', /, :trackable, :validatable$/, <<EOS
, :trackable, #:validatable, 
      :lockable, :lock_strategy => :none, :unlock_strategy => :none
  include EnjuSeed::EnjuUser
EOS
    generate("sunspot_rails:install")
    generate("kaminari:config")
    generate("kaminari:views bootstrap3")
    generate("simple_form:install")
    generate("geocoder:config")
    gsub_file "config/sunspot.yml",
      /path: \/solr\/production/,
      "path: /solr/default"
    gsub_file 'config/initializers/kaminari_config.rb',
      /# config.default_per_page = 25$/,
      "config.default_per_page = 10"
    generate("friendly_id")
    gsub_file "app/assets/javascripts/application.js",
      /\/\/= require turbolinks$/,
      ""
    gsub_file 'config/routes.rb', /devise_for :users$/, "devise_for :users, skip: [:registration]"
    inject_into_file 'config/routes.rb', after: /Rails.application.routes.draw do$\n/ do
      <<"EOS"
  authenticate :user, lambda {|u| u.role.try(:name) == 'Administrator' } do
    mount Resque::Server.new, at: "/resque", as: :resque
  end
EOS
    end
    gsub_file 'config/initializers/devise.rb', '# config.email_regexp = /\A[^@]+@[^@]+\z/', 'config.email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i'
    gsub_file 'config/initializers/devise.rb', '# config.authentication_keys = [:email]', 'config.authentication_keys = [:username]'
    gsub_file 'config/initializers/devise.rb', '# config.secret_key', 'config.secret_key'

    inject_into_class "app/controllers/application_controller.rb", ApplicationController do
      <<"EOS"
  include EnjuBiblio::Controller
  include EnjuLibrary::Controller

  include Pundit
  after_action :verify_authorized, unless: :devise_controller?
EOS
    end

    inject_into_file "app/assets/javascripts/application.js", after: /\/\/= require jquery_ujs$\n/ do
      "//= require enju_leaf/application\n"
    end
    inject_into_file "app/assets/stylesheets/application.css", after: / *= require_self$\n/ do
      " *= require enju_leaf/application\n"
    end
    inject_into_file "config.ru", after: /require ::File.expand_path\(\'..\/config\/environment\',  __FILE__\)$\n/ do
      <<"EOS"
require 'rack/protection'
use Rack::Protection, except: [:escaped_params, :json_csrf, :http_origin, :session_hijacking, :remote_token]
EOS
    end
    remove_file "public/index.html"
    remove_file "app/views/layouts/application.html.erb"
    gsub_file 'config/environments/production.rb',
      /config.serve_static_assets = false$/,
      "config.serve_static_assets = true"
    gsub_file 'config/environments/production.rb',
      /# config.cache_store = :mem_cache_store$/,
      "config.cache_store = :redis_store, ENV['REDIS_URL'], { expires_in: 1.day }"
    gsub_file 'config/environments/production.rb',
      /# config.assets.precompile \+= %w\( search.js \)$/,
      "config.assets.precompile += %w( mobile.js mobile.css print.css )"
  end
end
