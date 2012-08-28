class CopyNameToDisplayName < ActiveRecord::Migration
  def self.up
    models = %w(checkout_types circulation_statuses classification_types countries frequencies languages library_groups carrier_types patron_types request_status_types request_types shelves subject_heading_types subject_types use_restrictions user_groups form_of_works)
    models.each do |model|
      sql = "UPDATE #{model} SET display_name = name"
      execute(sql)
      change_column(model, :display_name, :text)
    end
  end

  def self.down
  end
end
