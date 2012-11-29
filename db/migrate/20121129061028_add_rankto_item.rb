class AddRanktoItem < ActiveRecord::Migration
  def change
    add_column :items, :rank, :integer, :default => 1
  end
end
