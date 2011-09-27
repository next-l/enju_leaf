class AddLftAndRgtToClassification < ActiveRecord::Migration
  def self.up
    add_column :classifications, :lft, :integer
    add_column :classifications, :rgt, :integer
  end

  def self.down
    remove_column :classifications, :rgt
    remove_column :classifications, :lft
  end
end
