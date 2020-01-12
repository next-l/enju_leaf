class EnjuLeaf::SeedGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def seed
    environment = ENV['RAILS_ENV'] || 'development'
    if !ENV['ENJU_SKIP_SOLR']
      if ENV['OS'] == 'Windows_NT'
        rake("sunspot:solr:run", env: environment)
      else
        rake("sunspot:solr:start", env: environment)
        sleep 5
      end
    end

    rake("enju_seed_engine:install:migrations")
    rake("enju_library_engine:install:migrations")
    rake("enju_biblio_engine:install:migrations")
    rake("enju_manifestation_viewer_engine:install:migrations")
    rake("enju_subject_engine:install:migrations")
    rake("enju_message_engine:install:migrations")
    rake("enju_event_engine:install:migrations")
    rake("enju_circulation_engine:install:migrations")
    rake("enju_inventory_engine:install:migrations")
    rake("enju_ndl_engine:install:migrations")
    rake("db:migrate", env: environment)
    rake("enju_leaf:setup", env: environment)
    rake("enju_circulation:setup", env: environment)
    rake("enju_subject:setup", env: environment)
    rake("assets:precompile", env: environment) if environment == 'production'
    rake("db:seed", env: environment)

    if !ENV['ENJU_SKIP_SOLR']
      rake("environment sunspot:reindex", env: environment)
      rake("sunspot:solr:stop", env: environment)
    end

    rake("enju_leaf:load_asset_files")
  end
end
