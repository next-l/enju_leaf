class AddLftAndRgtToClassification < ActiveRecord::Migration[4.2]
  def up
    add_column :classifications, :lft, :integer
    add_column :classifications, :rgt, :integer
  end

  def down
    remove_column :classifications, :rgt
    remove_column :classifications, :lft
  end
end
