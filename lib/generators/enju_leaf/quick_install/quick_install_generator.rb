class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    environment = ENV['RAILS_ENV'] || 'development'
    gsub_file 'config/schedule.rb', /^set :environment, :development$/,
      "set :environment, :#{environment}"
    rake("enju_seed_engine:install:migrations")
    rake("enju_library_engine:install:migrations")
    rake("enju_biblio_engine:install:migrations")
    rake("enju_manifestation_viewer_engine:install:migrations")
    rake("enju_subject_engine:install:migrations")
    rake("enju_inventory_engine:install:migrations")
    if !ENV['ENJU_SKIP_CONFIG']
      generate("enju_seed:setup")
      generate("enju_library:setup")
      generate("enju_biblio:setup")
      generate("enju_circulation:setup")
      generate("enju_subject:setup")
      generate("enju_inventory:setup")
    end
  end
end
