$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enju_trunk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enju_trunk"
  s.version     = EnjuTrunk::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of EnjuTrunk."
  s.description = "TODO: Description of EnjuTrunk."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.16"
  # s.add_dependency "jquery-rails"
  s.add_dependency 'roo', "1.10.1"
  s.add_dependency 'rubyzip', "0.9.9"
  s.add_dependency 'spreadsheet', '0.7.9'
  s.add_dependency 'axlsx', '~> 1.3.6'
  s.add_dependency 'rghost'
  s.add_dependency 'rghost_barcode'
  s.add_dependency 'rqrcode'
  s.add_dependency 'client_side_validations'
  s.add_dependency 'paranoia'
  s.add_dependency 'prawn', '1.0.0.rc1'
  s.add_dependency "rmagick"
  s.add_dependency 'parallel'
  s.add_dependency "jpp_customercode_transfer", "~> 0.0.2"
  s.add_dependency 'spinjs-rails'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'daemons'
  s.add_dependency 'exception_notification', '~> 4.0'
  s.add_dependency 'progress_bar'
  s.add_dependency 'acts-as-taggable-on', '~> 2.2'
  s.add_dependency 'ri_cal'
  s.add_dependency 'file_wrapper'
  s.add_dependency 'RedCloth', '>= 4.2.9'
  s.add_dependency 'scribd_fu'
  s.add_dependency 'omniauth', '>= 0.2.6'
  s.add_dependency 'barby', '~> 0.5'
  s.add_dependency 'chunky_png', '1.2.5'
  s.add_dependency 'geocoder'
  s.add_dependency 'cocaine', '0.4.2'
  s.add_dependency 'select2-rails'
  s.add_dependency 'devise', '~> 1.5'
  s.add_dependency 'rails_autolink'
  s.add_dependency 'sitemap_generator', '~> 3.0'
  s.add_dependency 'paper_trail', '~> 2.6'
  s.add_dependency 'simple_form', '~> 2.0'
  s.add_dependency 'sanitize'
  s.add_dependency 'dynamic_form'
  s.add_dependency 'lisbn'
  s.add_dependency 'library_stdnums'
  s.add_dependency 'awesome_nested_set'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'state_machine'
  s.add_dependency 'inherited_resources', '~> 1.3'
  s.add_dependency 'has_scope'
  s.add_dependency 'nori', '~> 2.0'
  s.add_dependency 'omniauth', '>= 0.2.6'
  s.add_dependency 'paperclip', '2.8'
  s.add_dependency 'select2-rails'
  s.add_dependency 'mobile-fu'
  s.add_dependency 'attribute_normalizer', '~> 1.1'
  s.add_dependency 'validates_timeliness'
  s.add_dependency 'rack-protection'


  s.add_development_dependency "sqlite3"
end
