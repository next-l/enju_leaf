namespace :enju_leaf do
  desc "Copy config files"

  config_files = [
    "config/application.yml",
    "db/seeds.rb"
  ]

  task :copy_config_files => config_files

  config_files.each do |config_file|
    file config_file do
      cp File.dirname(__FILE__) + "/../../#{config_file}", "#{Rails.root.to_s}/#{config_file}"
    end
  end

  fixture_dir = "#{Rails.root.to_s}/db/fixtures"
  directory fixture_dir
  task :copy_fixture_files => fixture_dir do
    cp Dir[File.dirname(__FILE__) + '/../../db/fixtures/*.yml'], fixture_dir
  end
end
