class AddParentIdToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :parent_id, :integer
    add_column :manifestations, :lft, :integer
    add_column :manifestations, :rgt, :integer
  end

  def self.down
    remove_column :manifestations, :rgt
    remove_column :manifestations, :lft
    remove_column :manifestations, :parent_id
  end
end
