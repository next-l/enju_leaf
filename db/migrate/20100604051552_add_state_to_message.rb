class AddStateToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :state, :string
    add_column :messages, :parent_id, :integer
    add_index :messages, :parent_id
  end

  def self.down
    remove_column :messages, :state
    remove_column :messages, :parent_id
  end
end
