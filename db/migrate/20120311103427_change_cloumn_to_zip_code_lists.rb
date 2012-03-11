class ChangeCloumnToZipCodeLists < ActiveRecord::Migration
  def up
    change_column :zip_code_lists, :zipcode5, :string
    change_column :zip_code_lists, :zipcode7, :string
  end

  def down
  end
end
