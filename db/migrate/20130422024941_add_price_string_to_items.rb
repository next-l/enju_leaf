class AddPriceStringToItems < ActiveRecord::Migration
  def change
    add_column :items, :price_string, :string
  end
end
