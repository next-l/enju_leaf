class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.string :name
      t.text :note
      t.float :height
      t.float :width
      t.float :cell_h
      t.float :cell_w
      t.float :margin_h
      t.float :margin_w
      t.float :space_h
      t.float :space_w
      t.integer :cell_x
      t.integer :cell_y

      t.timestamps
    end
  end
end
