class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :provider
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :identities, :name
    add_index :identities, :email
    add_index :identities, :provider
    add_index :identities, :user_id
  end
end
