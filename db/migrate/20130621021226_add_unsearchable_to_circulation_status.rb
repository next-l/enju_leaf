class AddUnsearchableToCirculationStatus < ActiveRecord::Migration
  def change
    add_column :circulation_statuses, :unsearchable, :boolean
  end
end
