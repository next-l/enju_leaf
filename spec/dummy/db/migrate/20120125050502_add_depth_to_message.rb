class AddDepthToMessage < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :depth, :integer

  end
end
