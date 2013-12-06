class AddColumnForBookbinderToManifestation < ActiveRecord::Migration
  def up
    add_column :manifestations, :bookbinder, :boolean, :default => false
  end

  def down
    remove_column :manifestations, :bookbinder
  end
end
