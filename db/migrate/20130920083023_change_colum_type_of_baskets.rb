class ChangeColumTypeOfBaskets < ActiveRecord::Migration
  def up
    remove_column :baskets, :type
    add_column :baskets, :basket_type, :integer, :default => 0, :null => false
  end

  def down
    remove_column :baskets, :basket_type
    add_column :baskets, :type, :string
  end
end
