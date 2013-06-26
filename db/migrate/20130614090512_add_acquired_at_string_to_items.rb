class AddAcquiredAtStringToItems < ActiveRecord::Migration
  def change
    add_column :items, :acquired_at_string, :string
  end
end
