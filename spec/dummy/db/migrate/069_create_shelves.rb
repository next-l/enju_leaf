class CreateShelves < ActiveRecord::Migration[5.2]
  def change
    create_table :shelves do |t|
      t.string :name, null: false
      t.text :note, comment: '備考'
      t.references :library, index: true, null: false
      t.integer :items_count, default: 0, null: false
      t.integer :position
      t.timestamps
    end
  end
end
