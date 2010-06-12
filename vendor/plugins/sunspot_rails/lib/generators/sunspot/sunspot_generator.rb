class SunspotGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_sunspot_file
    copy_file "sunspot.yml", "config/sunspot.yml"
  end

end
