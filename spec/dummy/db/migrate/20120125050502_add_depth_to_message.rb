class AddDepthToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :depth, :integer

  end
end
