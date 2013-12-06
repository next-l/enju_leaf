class AddNonSearchableToItems < ActiveRecord::Migration
  def change
    add_column :items, :non_searchable, :boolean, :default => false, :null => true
  end
end
