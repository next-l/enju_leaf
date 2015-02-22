class AddNdcToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :ndc, :string
  end

  def self.down
    remove_column :manifestations, :ndc
  end
end
