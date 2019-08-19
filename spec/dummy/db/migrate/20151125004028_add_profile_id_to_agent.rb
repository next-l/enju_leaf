class AddProfileIdToAgent < ActiveRecord::Migration[5.2]
  def change
    add_column :agents, :profile_id, :integer
    add_index :agents, :profile_id
  end
end
