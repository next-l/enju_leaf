class CreateWithdraws < ActiveRecord::Migration[5.1]
  def change
    create_table :withdraws do |t|
      t.references :basket, foreign_key: {on_delete: :nullify}, type: :uuid
      t.references :item, foreign_key: true, type: :uuid
      t.references :librarian, foreign_key: {to_table: :users}, null: false

      t.timestamps
    end
  end
end
