class CreateCheckouts < ActiveRecord::Migration[5.1]
  def change
    create_table :checkouts, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :user, foreign_key: true
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :librarian, foreign_key: {to_table: :users}
      t.datetime :due_date
      t.integer :checkout_renewal_count, default: 0, null: false
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end
  end
end
