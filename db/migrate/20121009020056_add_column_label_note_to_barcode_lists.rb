class AddColumnLabelNoteToBarcodeLists < ActiveRecord::Migration
  def change
    add_column :barcode_lists, :label_note, :string
  end
end
