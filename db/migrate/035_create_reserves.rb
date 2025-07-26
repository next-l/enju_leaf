class CreateReserves < ActiveRecord::Migration[4.2]
  def up
    create_table :reserves do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :manifestation, index: true, null: false
      t.references :item, index: true
      t.references :request_status_type, null: false
      t.datetime :checked_out_at
      t.timestamps
      t.datetime :canceled_at
      t.datetime :expired_at
      t.datetime :deleted_at
      t.boolean :expiration_notice_to_patron, default: false
      t.boolean :expiration_notice_to_library, default: false
    end
  end

  def down
    drop_table :reserves
  end
end
