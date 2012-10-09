class FixColumnnameSheetTypeToSheetId < ActiveRecord::Migration
  def change
    rename_column :barcode_lists, :sheet_type, :sheet_id
  end

end
