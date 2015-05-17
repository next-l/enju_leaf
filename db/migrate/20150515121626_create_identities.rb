class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :name
      t.string :email
      t.string :password_digest

      t.timestamps null: false
    end
    add_index :identities, :name
    add_index :identities, :email
  end
end
