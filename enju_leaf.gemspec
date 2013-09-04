$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_leaf/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_leaf"
  s.version     = EnjuLeaf::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["tanabe@mwr.mediacom.keio.ac.jp"]
  s.homepage    = "https://github.com/nabeta/enju_leaf"
  s.summary     = "Next-L Enju Leaf"
  s.description = "integrated library system"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids}/*"]

  #s.add_dependency "enju_biblio", "~> 0.1.0.pre44"
  #s.add_dependency "enju_library", "~> 0.1.0.pre25"
  #s.add_dependency "enju_manifestation_viewer", "~> 0.1.0.pre11"
  s.add_dependency "redcarpet"
  s.add_dependency "mobylette", "~> 3.4"
  s.add_dependency "sitemap_generator"
  s.add_dependency "devise-encryptable"
  s.add_dependency "redis-rails", "~> 4.0"
  s.add_dependency "rails_autolink"
  s.add_dependency "jquery-ui-rails"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "enju_message", "~> 0.1.14.pre11"
  s.add_development_dependency "vcr"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "sunspot_solr", "~> 2.0.0"
  s.add_development_dependency "sunspot-rails-tester"
end
