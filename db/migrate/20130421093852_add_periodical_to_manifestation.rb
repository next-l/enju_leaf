class AddPeriodicalToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :periodical, :boolean
  end
end
