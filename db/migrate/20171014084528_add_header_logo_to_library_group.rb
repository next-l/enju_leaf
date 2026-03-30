class AddHeaderLogoToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
    change_table :library_groups do |t|
      t.string :header_logo_content_type
      t.string :header_logo_file_name
      t.bigint :header_logo_file_size
      t.datetime :header_logo_updated_at
    end
  end
end
