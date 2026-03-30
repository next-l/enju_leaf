class AddHeaderLogoToLibraryGroup < ActiveRecord::Migration[4.2]
  def change
<<<<<<< HEAD
    change_table :library_groups do |t|
      t.string :header_logo_content_type
      t.string :header_logo_file_name
      t.bigint :header_logo_file_size
      t.datetime :header_logo_updated_at
    end
=======
    add_column :library_groups, :header_logo_content_type, :string
    add_column :library_groups, :header_logo_file_name, :string
    add_column :library_groups, :header_logo_file_size, :integer
>>>>>>> main
  end
end
