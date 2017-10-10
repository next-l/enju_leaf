class AddPeriodicalToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :periodical, :boolean
  end
end
