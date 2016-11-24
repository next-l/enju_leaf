class CreateReserves < ActiveRecord::Migration
  def self.up
    create_table :reserves do |t|
      t.references :user, null: false, index: true
      t.references :manifestation, null: false, index: true
      t.references :item, index: true
      t.references :request_status_type, null: false, index: true
      t.datetime :checked_out_at
      t.timestamps
      t.datetime :canceled_at
      t.datetime :expired_at
      t.datetime :deleted_at
      t.boolean :expiration_notice_to_patron, default: false
      t.boolean :expiration_notice_to_library, default: false
    end
  end

  def self.down
    drop_table :reserves
  end
end
