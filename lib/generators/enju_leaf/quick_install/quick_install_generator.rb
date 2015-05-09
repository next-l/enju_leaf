class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    environment = ENV['ENJU_ENV'] || 'development'
    if !ENV['SKIP_CONFIG']
      rake("db:migrate", env: environment)
      generate("enju_circulation:setup")
      generate("enju_subject:setup")
    end
    rake("db:migrate", env: environment)
    rake("enju_leaf:setup", env: environment)
    rake("enju_circulation:setup", env: environment)
    rake("enju_subject:setup", env: environment)
    rake("assets:precompile", env: environment) if environment == 'production'
    rake("db:seed", env: environment)
    if ENV['OS'] == 'Windows_NT'
      rake("sunspot:solr:run", env: environment)
    else
      rake("sunspot:solr:start", env: environment)
      sleep 5
      rake("environment enju_leaf:reindex", env: environment)
      rake("sunspot:solr:stop", env: environment)
    end
  end
end
