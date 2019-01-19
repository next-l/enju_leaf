class AddDepthToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :depth, :integer
  end
end
