class AddCreateTypeToCreate < ActiveRecord::Migration[4.2]
  def change
    add_column :creates, :create_type_id, :integer
    add_column :realizes, :realize_type_id, :integer
    add_column :produces, :produce_type_id, :integer
  end
end
