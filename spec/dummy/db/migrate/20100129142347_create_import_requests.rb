class CreateImportRequests < ActiveRecord::Migration
  def change
    create_table :import_requests do |t|
      t.string :isbn
      t.integer :manifestation_id
      t.integer :user_id

      t.timestamps
    end
    add_index :import_requests, :isbn
    add_index :import_requests, :manifestation_id
    add_index :import_requests, :user_id
  end
end
