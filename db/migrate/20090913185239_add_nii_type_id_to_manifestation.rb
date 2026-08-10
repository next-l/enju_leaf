class AddNiiTypeIdToManifestation < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestations, :nii_type_id, :integer, if_not_exists: true
    add_index :manifestations, :nii_type_id, if_not_exists: true
  end

  def down
    remove_column :manifestations, :nii_type_id
  end
end
