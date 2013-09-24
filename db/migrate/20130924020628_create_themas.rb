class CreateThemas < ActiveRecord::Migration
  def change
    create_table :themas do |t|
      t.string :name
      t.string :display_name
      t.text :description
      t.integer :publish
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
