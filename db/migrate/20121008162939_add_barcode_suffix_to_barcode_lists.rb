class AddBarcodeSuffixToBarcodeLists < ActiveRecord::Migration
  def change
    add_column :barcode_lists, :barcode_suffix, :string

    BarcodeList.all.each {|b|
      if b.usage_type = "user"
        b.usage_type = "2"
        b.save!
      elsif b.usage_type = "item"
        b.usage_type = "3"
      end
    }
  end
end
