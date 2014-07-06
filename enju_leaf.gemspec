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
  s.test_files = Dir["spec/**/*"] - Dir["spec/dummy/log/*"] - Dir["spec/dummy/solr/{data,pids}/*"]

  s.add_dependency "rails", "~> 4.1.4"
  s.add_dependency "enju_seed", "~> 0.2.0.pre6"
  #s.add_dependency "enju_biblio", "~> 0.2.0.pre1"
  #s.add_dependency "enju_library", "~> 0.2.0.pre1"
  #s.add_dependency "enju_manifestation_viewer", "~> 0.2.0.pre1"
  #s.add_dependency "mobylette", "~> 3.5"
  s.add_dependency "browser", "~> 0.4"
  s.add_dependency "sitemap_generator", "~> 5.0"
  s.add_dependency "devise-encryptable"
  s.add_dependency "redis-rails", "~> 4.0"
  s.add_dependency "rails_autolink"
  s.add_dependency "jquery-ui-rails", "~> 5.0"
  s.add_dependency "resque-scheduler", "~> 3.0"
  s.add_dependency "paperclip", "~> 4.1"
  if RUBY_PLATFORM == "java"
    s.add_dependency "kramdown"
  else
    s.add_dependency "redcarpet"
  end
  # s.add_dependency "jquery-rails"

  if RUBY_PLATFORM == "java"
    s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
  else
    s.add_development_dependency "sqlite3"
  end
  s.add_development_dependency "rspec-rails", "~> 3.0"
  #s.add_development_dependency "enju_message", "~> 0.2.0.pre1"
  s.add_development_dependency "vcr"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "elasticsearch-extensions"
  s.add_development_dependency "annotate"
  s.add_development_dependency "rspec-activemodel-mocks"
end
