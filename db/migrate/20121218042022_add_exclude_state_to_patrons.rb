class AddExcludeStateToPatrons < ActiveRecord::Migration
  def change
    add_column :patrons, :exclude_state, :integer, :default => 0
  end
end
