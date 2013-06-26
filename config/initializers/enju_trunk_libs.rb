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

# custom validator
if defined?(EnjuCustomize)
  begin
    require EnjuCustomize.render_dir + '/custom_validator'
  rescue
    # NO CUSTOM VALIDATOR
  end
end
