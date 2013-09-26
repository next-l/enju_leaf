class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :name, null: false
      t.text :description
      t.integer :publish, null: false, :default => 0
      t.text :note
      t.integer :position, null: false, :default => 0

      t.timestamps
    end
  end
end
