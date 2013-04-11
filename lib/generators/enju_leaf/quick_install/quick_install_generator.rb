class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    environment = ENV['RAILS_ENV'] ||= 'development'
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
    rake("db:migrate")
    rake("enju_leaf:setup")
    rake("enju_circulation:setup")
    rake("enju_subject:setup")
    #rake("sunspot:solr:start")
    #rake("db:seed")
    rake("assets:precompile") if environment == 'production'
  end
end
