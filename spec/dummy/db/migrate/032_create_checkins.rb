class CreateCheckins < ActiveRecord::Migration[5.0]
  def change
    create_table :checkins do |t|
      t.references :item, null: false, type: :uuid
      t.integer :librarian_id, null: false
      t.references :basket, null: false
      t.timestamps
    end
    add_index :checkins, :librarian_id
  end
end
