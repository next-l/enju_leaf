class AddReceiptLibraryIdToReserves < ActiveRecord::Migration
  def self.up
    add_column :reserves, :receipt_library_id, :integer
    add_column :reserves, :information_type_id, :integer
  end

  def self.down
    remove_column :reserves, :receipt_library_id
    remove_column :reserves, :information_type_id
  end
end
