class CreateCheckins < ActiveRecord::Migration[5.1]
  def change
    create_table :checkins do |t|
      t.references :checkout, foreign_key: true, null: false, type: :uuid
      t.references :librarian, foreign_key: {to_table: :users}, null: false
      t.references :basket, foreign_key: true, null: false, type: :uuid
      t.timestamps
    end
  end
end
