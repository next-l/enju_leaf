class AddNiiTypeIdToResource < ActiveRecord::Migration
  def self.up
    add_column :resources, :nii_type_id, :integer
    add_index :resources, :nii_type_id
  end

  def self.down
    remove_column :resources, :nii_type_id
  end
end
