class CreateCheckins < ActiveRecord::Migration[4.2]
  def up
    create_table :checkins do |t|
      t.references :item, index: true, foreign_key: true, null: false
      t.references :librarian, index: true
      t.references :basket, index: true
      t.timestamps
    end
  end

  def down
    drop_table :checkins
  end
end
