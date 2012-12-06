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

  desc 'setup Next-L Enju'
  task :setup => [
    'config/initializers/secret_token.rb',
    'db:create',
    'db:migrate'
  ]
end
