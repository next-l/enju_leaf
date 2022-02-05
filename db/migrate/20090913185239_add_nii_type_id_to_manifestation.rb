class AddNiiTypeIdToManifestation < ActiveRecord::Migration[4.2]
  def self.up
    add_column :manifestations, :nii_type_id, :integer
    add_index :manifestations, :nii_type_id
  end

  def self.down
    remove_column :manifestations, :nii_type_id
  end
end
