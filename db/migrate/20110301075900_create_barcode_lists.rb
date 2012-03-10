class CreateBarcodeLists < ActiveRecord::Migration
  def change
    create_table(:barcode_lists) do |t|
      t.string :barcode_name
      t.string :usage_type
      t.string :barcode_type
      t.string :barcode_prefix
      t.integer :printed_number
      t.integer :sheet_type
      t.integer :last_number

      t.timestamps
    end
  end
end
