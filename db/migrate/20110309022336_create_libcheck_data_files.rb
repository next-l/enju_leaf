class CreateLibcheckDataFiles < ActiveRecord::Migration
  def self.up
    create_table :libcheck_data_files do |t|
      t.integer :library_check_id, :null=> false
      t.string :file_name, :null => false
      t.datetime :uploaded_at
    end
  end

  def self.down
    drop_table :libcheck_data_files
  end
end
