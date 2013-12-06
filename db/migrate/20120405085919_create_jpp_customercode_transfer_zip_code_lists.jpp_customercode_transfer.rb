# This migration comes from jpp_customercode_transfer (originally 20120401133633)
class CreateJppCustomercodeTransferZipCodeLists < ActiveRecord::Migration
  def change
    create_table :jpp_customercode_transfer_zip_code_lists do |t|
      t.string :union_code
      t.string :zipcode5
      t.string :zipcode
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
