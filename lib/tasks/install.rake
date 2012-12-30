namespace :enju do
  file 'config/initializers/secret_token.rb' do |file|
    File.open(file.name, 'w') do |f|
      f.write <<"EOF"
EnjuLeaf::Application.config.secret_token = "#{SecureRandom.hex(64)}"
EOF
    end
  end

  desc 'generate a secret token'
  task :generate_secret_token => ['config/initializers/secret_token.rb']

  config_files = [
    "config/application.yml",
    "config/environments/production.rb",
    "config/initializers/devise.rb",
    "config/initializers/geocoder.rb",
    "config/resque.yml",
    "config/schedule.rb",
    "config/sunspot.yml",
    "db/seeds.rb"
  ]

  config_files.each do |config_file|
    file config_file do |conf|
      cp "#{conf.name}.sample", conf.name
    end
  end

  desc 'copy config files'
  task :copy_config_files => config_files

  desc 'setup Next-L Enju'
  task :setup => [
    'enju:copy_config_files',
    'enju:generate_secret_token',
    'db:create',
    'db:migrate'
  ]
end
