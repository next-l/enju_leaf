class CreateLibraryChecks < ActiveRecord::Migration
  def self.up
    create_table(:library_checks) do |t|
      t.string :opeym, :null => false
      t.string :shelf_def_file
      t.integer :status, :default => 0
      t.datetime :operated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :library_checks
  end
end
