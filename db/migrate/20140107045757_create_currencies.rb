class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.integer :id
      t.string :name, null: false
      t.string :display_name, null: false
      t.timestamp :created_at
      t.timestamp :updated_at

      t.timestamps
    end
  end
end
