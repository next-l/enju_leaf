class CreateBarcodes < ActiveRecord::Migration
  def self.up
    create_table :barcodes do |t|
      t.string :barcode_type, :default => 'Code128B', :null => false
      t.integer :barcodable_id
      t.string :barcodable_type
      t.string :code_word
      t.binary :data

      t.timestamps
    end
    add_index :barcodes, [:barcodable_id, :barcodable_type]
    add_index :barcodes, [:barcode_type, :code_word]
  end

  def self.down
    drop_table :barcodes
  end
end
