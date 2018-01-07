class AddProfileIdToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :profile_id, :integer
    add_index :agents, :profile_id
  end
end
