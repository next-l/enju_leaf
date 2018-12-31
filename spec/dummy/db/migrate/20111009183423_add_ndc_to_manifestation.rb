class AddNdcToManifestation < ActiveRecord::Migration[4.2]
  def self.up
    add_column :manifestations, :ndc, :string
  end

  def self.down
    remove_column :manifestations, :ndc
  end
end
