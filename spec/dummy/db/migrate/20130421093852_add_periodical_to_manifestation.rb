class AddPeriodicalToManifestation < ActiveRecord::Migration[5.0]
  def change
    add_column :manifestations, :periodical, :boolean
  end
end
