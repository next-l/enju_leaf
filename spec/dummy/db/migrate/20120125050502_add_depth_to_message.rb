class AddDepthToMessage < ActiveRecord::Migration[4.2]
  def change
    add_column :messages, :depth, :integer
  end
end
