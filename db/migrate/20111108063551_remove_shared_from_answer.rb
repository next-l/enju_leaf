class RemoveSharedFromAnswer < ActiveRecord::Migration
  def up
    remove_column :answers, :shared
  end

  def down
    add_column :answers, :shared, :boolean, :default => true, :null => false
  end
end
