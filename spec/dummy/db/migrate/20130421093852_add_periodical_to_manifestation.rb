class AddPeriodicalToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :periodical, :boolean, default: false, null: false
  end
end
