class AddNcidToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :ncid, :string
    add_index :manifestations, :ncid
  end
end
