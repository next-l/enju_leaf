class EnjuTrunk::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  desc "Create a setup file for Next-L Enju"

  def copy_setup_files
    copy_file("config/config.yml", "config/config.yml")
    copy_file("config/resque.yml", "config/resque.yml")
    copy_file("config/schedule.rb", "config/schedule.rb")
    copy_file("db/seeds.rb", "db/seeds.rb")
    directory("db/fixtures", "db/fixtures")
    copy_file("app/controllers/application_controller.rb", "app/controllers/application_controller.rb")
    gsub_file 'config/application.rb', /# config.i18n.default_locale = :de$/,
      "config.i18n.default_locale = :ja"
    gsub_file 'config/application.rb', /# config.time_zone = 'Central Time \(US & Canada\)'$/,
      "config.time_zone = 'Tokyo'"
    gsub_file 'config/schedule.rb', /\/path\/to\/enju_leaf/, Rails.root.to_s
    append_to_file("Rakefile", "require 'resque/tasks'")
    append_to_file 'config/initializers/inflections.rb',  <<EOS
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'reserve', 'reserves'
end
EOS
    append_to_file 'app/assets/javascripts/application.js', <<EOS
//= require enju_trunk
EOS
    append_to_file 'app/assets/stylesheets/application.css', <<EOS
 *= require enju_trunk
EOS
    inject_into_file 'config/environments/development.rb',
      "  config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n",
      :after => "::Application.configure do\n"
    inject_into_file 'config/environments/test.rb',
      "  config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n",
      :after => "::Application.configure do\n"
    inject_into_file 'config/environments/production.rb',
      "  config.action_mailer.default_url_options = {:host => 'localhost:3000'}\n",
      :after => "::Application.configure do\n"
    generate("devise:install")
    rake("enju_trunk_engine:install:migrations")
    inject_into_file 'config/routes.rb', :after => /Application.routes.draw do$\n/ do
      "devise_for :users, :path => 'accounts'"
    end
    gsub_file 'config/initializers/devise.rb', '# config.email_regexp = /\A[^@]+@[^@]+\z/', 'config.email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\Z/i'
    gsub_file 'config/initializers/devise.rb', '# config.authentication_keys = [ :email ]', 'config.authentication_keys = [ :username ]'
    inject_into_file "config.ru", :after => /require ::File.expand_path\(\'..\/config\/environment\',  __FILE__\)$\n/ do
      <<"EOS"
require 'rack/protection'
use Rack::Protection, :except => [:escaped_params, :json_csrf, :http_origin, :session_hijacking, :remote_token]
EOS
    end
    generate("sunspot_rails:install")
    gsub_file "config/sunspot.yml",
      /path: \/solr\/production/,
      "path: /solr/default"
    generate("kaminari:config")
    generate("simple_form:install")
    gsub_file 'config/initializers/kaminari_config.rb',
      /# config.default_per_page = 25$/,
      "config.default_per_page = 10"
    remove_file "public/index.html"
    remove_file "app/helpers/application_helper.rb"
    remove_file "app/views/layouts/application.html.erb"
  end
end
