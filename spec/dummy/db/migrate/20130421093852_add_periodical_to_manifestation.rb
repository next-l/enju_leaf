class AddPeriodicalToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :periodical, :boolean
  end
end
