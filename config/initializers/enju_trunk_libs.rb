Dir[Rails.root.to_s + "/lib/enju_trunk/**/base.rb"].each do 
  |file|
  require file
end
Dir[Rails.root.to_s + "/lib/enju_trunk/**/*.rb"].each do 
  |file|
  require file
end

# nacsis
begin
  NACSIS_CLIENT_CONFIG = YAML.load_file("#{Rails.root}/config/nacsis_client.yml")
rescue Errno::ENOENT
  # skip.
end
