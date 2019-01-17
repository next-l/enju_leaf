class CreateWithdraws < ActiveRecord::Migration[5.2]
  def change
    create_table :withdraws do |t|
      t.references :basket, index: true
      t.references :item, index: true
      t.references :librarian, index: true

      t.timestamps null: false
    end
  end
end
