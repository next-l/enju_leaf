class AddMissingSinceToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :missing_since, :date
  end
end
