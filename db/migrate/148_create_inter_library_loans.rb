class CreateInterLibraryLoans < ActiveRecord::Migration
  def self.up
    create_table :inter_library_loans do |t|
      t.integer :item_id, :null => false
      t.integer :borrowing_library_id, :null => false
      t.timestamp :requested_at
      t.timestamp :shipped_at
      t.timestamp :received_at
      t.timestamp :return_shipped_at
      t.timestamp :return_received_at
      t.timestamp :deleted_at
      t.string :state

      t.timestamps
    end
    add_index :inter_library_loans, :item_id
    add_index :inter_library_loans, :borrowing_library_id
  end

  def self.down
    drop_table :inter_library_loans
  end
end
