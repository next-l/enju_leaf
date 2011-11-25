class RemovePeriodicalFromManifestation < ActiveRecord::Migration
  def up
    remove_column :manifestations, :periodical
  end

  def down
    add_column :manifestations, :periodical, :boolean
  end
end
