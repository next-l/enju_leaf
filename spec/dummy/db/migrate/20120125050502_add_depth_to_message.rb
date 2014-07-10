class AddDepthToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :depth, :integer

  end
end
