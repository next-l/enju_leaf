class CreateMediumOfPerformances < ActiveRecord::Migration
  def self.up
    create_table :medium_of_performances do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :medium_of_performances
  end
end
