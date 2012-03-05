class CreateZipCodeLists < ActiveRecord::Migration
  def change
    create_table :zip_code_lists do |t|
      t.integer :union_code
      t.integer :zipcode5
      t.integer :zipcode7
      t.string :prefectrure_name_kana
      t.string :city_name_kana
      t.string :region_name_kana
      t.string :prefecture_name
      t.string :city_name
      t.string :region_name
      t.integer :flag10
      t.integer :flag11
      t.integer :flag12
      t.integer :flag13
      t.integer :flag14
      t.integer :update_flag

      t.timestamps
    end
  end
end
