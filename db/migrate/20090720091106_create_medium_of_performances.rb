class CreateMediumOfPerformances < ActiveRecord::Migration
  def change
    create_table :medium_of_performances do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
