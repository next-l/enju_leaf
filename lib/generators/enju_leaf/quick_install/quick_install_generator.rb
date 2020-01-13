class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    generate("devise:install")
    generate("devise", "User")
    remove_file "db/migrate/*devise_create_users.rb"
    gsub_file 'app/models/user.rb', /, :registerable,$/, ', #:registerable,'
    gsub_file 'app/models/user.rb', /, :validatable$/, <<EOS
, #:validatable,
      :lockable, lock_strategy: :none, unlock_strategy: :none
EOS

    environment = ENV['RAILS_ENV'] || 'development'
    gsub_file 'config/schedule.rb', /^set :environment, :development$/,
      "set :environment, :#{environment}"
    gsub_file 'config/routes.rb', /devise_for :users$/, "devise_for :users, skip: [:registration]"
    inject_into_file 'config/routes.rb', after: /Rails.application.routes.draw do$\n/ do
      <<"EOS"
  authenticate :user, lambda {|u| u.role.try(:name) == 'Administrator' } do
    mount Resque::Server.new, at: "/resque", as: :resque
  end

  as :user do
    get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users' => 'devise/registrations#update', as: 'user_registration'
  end
EOS
    end
    gsub_file 'config/initializers/devise.rb', '# config.email_regexp = /\A[^@]+@[^@]+\z/', 'config.email_regexp = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i'
    gsub_file 'config/initializers/devise.rb', '# config.authentication_keys = [:email]', 'config.authentication_keys = [:username]'

    if !ENV['ENJU_SKIP_CONFIG']
      generate("enju_seed:setup")
      generate("enju_library:setup")
      generate("enju_biblio:setup")
      generate("enju_circulation:setup")
      generate("enju_subject:setup")
      generate("enju_inventory:setup")
    end
    append_to_file "app/models/user.rb", <<EOS.strip_heredoc
      Manifestation.include(EnjuManifestationViewer::EnjuManifestation)
      Manifestation.include(EnjuNdl::EnjuManifestation)
EOS
  end
end
