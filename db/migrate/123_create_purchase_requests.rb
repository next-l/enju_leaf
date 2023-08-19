class CreatePurchaseRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :purchase_requests do |t|
      t.references :user, foreign_key: true, null: false
      t.text :title, null: false
      t.text :author
      t.text :publisher
      t.string :isbn
      t.datetime :date_of_publication
      t.integer :price
      t.string :url
      t.text :note
      t.datetime :accepted_at
      t.datetime :denied_at
      t.string :state
      t.string :pub_date

      t.timestamps
    end

    add_index :purchase_requests, :state
  end
end
