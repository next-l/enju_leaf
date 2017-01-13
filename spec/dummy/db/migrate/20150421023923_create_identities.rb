class CreateIdentities < ActiveRecord::Migration[5.0]
  def change
    create_table :identities do |t|
      t.string :name, index: true
      t.string :email, index: true
      t.string :password_digest
      t.references :profile, index: true

      t.timestamps
    end
  end
end
