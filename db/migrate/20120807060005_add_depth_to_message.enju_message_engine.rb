# This migration comes from enju_message_engine (originally 20120125050502)
class AddDepthToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :depth, :integer

  end
end
