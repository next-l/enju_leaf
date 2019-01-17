class AddCsvCharsetConversionToLibraryGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :library_groups, :csv_charset_conversion, :boolean, null: false, default: false
  end
end
