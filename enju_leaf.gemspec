$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_leaf/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_leaf"
  s.version     = EnjuLeaf::VERSION
  s.authors     = ["Kosuke Tanabe"]
  s.email       = ["nabeta@fastmail.fm"]
  s.homepage    = "https://github.com/next-l/enju_leaf"
  s.summary     = "Next-L Enju Leaf"
  s.description = "integrated library system"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids,default,development,test}/*"] - Dir["spec/dummy/tmp/*"]

  s.add_dependency "rails", ">= 3.2.22", "< 5.0"
  s.add_dependency "enju_biblio", "~> 0.1.0.pre68"
  s.add_dependency "enju_library", "~> 0.1.0.pre43"
  s.add_dependency "enju_manifestation_viewer", "~> 0.1.0.pre18"
  s.add_dependency "friendly_id", ">= 4.0"
  s.add_dependency "kaminari", "~> 0.16.3"
  s.add_dependency "devise", "~> 3.5"
  s.add_dependency "cancancan", "~> 1.12"
  s.add_dependency "acts_as_list", "~> 0.7"
  s.add_dependency "attribute_normalizer", "~> 1.2"
  s.add_dependency "addressable"
  s.add_dependency "sunspot_rails", "~> 2.2"
  s.add_dependency "resque"
  s.add_dependency "dalli"
  s.add_dependency "nested_form"
  s.add_dependency "mobylette", "~> 3.5"
  s.add_dependency "sitemap_generator", "~> 5.1"
  s.add_dependency "devise-encryptable"
  s.add_dependency "redis-rails"
  s.add_dependency "rails_autolink"
  s.add_dependency "jquery-ui-rails", "~> 4.2.1"
  s.add_dependency "resque-scheduler", "~> 4.0"
  s.add_dependency "paperclip", "~> 4.2"
  s.add_dependency "statesman"
  s.add_dependency "kramdown"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.3"
  s.add_development_dependency "enju_circulation", "~> 0.1.0.pre47"
  s.add_development_dependency "enju_bookmark", "~> 0.1.2.pre22"
  s.add_development_dependency "enju_search_log", "~> 0.1.0.pre11"
  s.add_development_dependency "vcr"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "sunspot_solr", "~> 2.2"
  s.add_development_dependency "sunspot-rails-tester"
  s.add_development_dependency "annotate"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "charlock_holmes"
  s.add_development_dependency "appraisal"
  s.add_development_dependency "capybara"
end
