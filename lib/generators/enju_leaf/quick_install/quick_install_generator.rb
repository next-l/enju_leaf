class EnjuLeaf::QuickInstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def quick_install
    if !ENV['SKIP_CONFIG']
      rake("db:migrate")
      generate("enju_circulation:setup")
      generate("enju_subject:setup")
    end
    rake("db:migrate")
    rake("enju_leaf:setup")
    rake("enju_circulation:setup")
    rake("enju_subject:setup")
    rake("assets:precompile")
    rake("db:seed")
    if ENV['OS'] == 'Windows_NT'
      rake("sunspot:solr:run")
    else
      rake("sunspot:solr:start")
      sleep 5
      rake("environment enju_leaf:reindex")
      rake("sunspot:solr:stop")
    end
  end
end
