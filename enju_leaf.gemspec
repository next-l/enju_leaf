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

  s.required_ruby_version = ">= 2.1"

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/{log,private,solr,tmp}/**/*"] - Dir["spec/dummy/db/*.sqlite3"]

  s.add_dependency "rails", ">= 4.2.8"
  s.add_dependency "enju_biblio", "~> 0.2.0"
  s.add_dependency "jquery-ui-rails", "~> 4.2.1"
  s.add_dependency "turbolinks", "~> 2.5"

  s.add_development_dependency "enju_manifestation_viewer", "~> 0.2.0"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "vcr", "~> 3.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "sunspot_matchers"
  s.add_development_dependency "rspec-activemodel-mocks"
  s.add_development_dependency "resque"
  s.add_development_dependency "charlock_holmes"
  s.add_development_dependency "capybara"
  s.add_development_dependency "coveralls"
  s.add_development_dependency "appraisal"
end
