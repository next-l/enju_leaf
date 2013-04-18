class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    environment = ENV['ENJU_ENV'] || 'development'
    rake("db:migrate", :env => environment)
    generate("enju_circulation:setup")
    generate("enju_subject:setup")
    gsub_file 'config/schedule.rb', /^set :environment, :development$/,
      "set :environment, :#{environment}"
    gsub_file 'config/environments/production.rb',
      /config.serve_static_assets = false$/,
      "config.serve_static_assets = true"
    gsub_file 'config/environments/production.rb',
      /# config.cache_store = :mem_cache_store$/,
      "config.cache_store = :dalli_store, {:compress => true}"
    gsub_file 'config/environments/production.rb',
      /# config.assets.precompile \+= %w\( search.js \)$/,
      "config.assets.precompile += %w( mobile.js mobile.css print.css )"
    rake("db:migrate", :env => environment)
    rake("enju_leaf:setup", :env => environment)
    rake("enju_circulation:setup", :env => environment)
    rake("enju_subject:setup", :env => environment)
    rake("assets:precompile") if environment == 'production'
    rake("db:seed", :env => environment)
    if ENV['OS'] == 'Windows_NT'
      rake("sunspot:solr:run", :env => environment)
    else
      rake("sunspot:solr:start", :env => environment)
      rake("enju_leaf:create_initial_index", :env => environment)
      rake("sunspot:solr:stop", :env => environment)
    end
  end
end
