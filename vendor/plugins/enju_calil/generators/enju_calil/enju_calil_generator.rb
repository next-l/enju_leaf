class EnjuCalilGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "enju_calil_add_neighborhood_calil_systemid_to_#{table_name}"
    end
  end

end
