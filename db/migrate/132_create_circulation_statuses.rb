class CreateCirculationStatuses < ActiveRecord::Migration
  def change
    create_table :circulation_statuses do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
