class CreateRetainAndCheckouts < ActiveRecord::Migration[5.1]
  def change
    create_table :retain_and_checkouts do |t|
      t.references :retain, foreign_key: {on_delete: :cascade}, null: false
      t.references :checkout, foreign_key: {on_delete: :cascade}, null: false, type: :uuid

      t.timestamps
    end
  end
end
