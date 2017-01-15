class CreateReserves < ActiveRecord::Migration[5.0]
  def self.up
    create_table :reserves do |t|
      t.references :user, foreign_key: true, null: false
      t.references :manifestation, foreign_key: true, null: false, type: :uuid
      t.references :item, foreign_key: true, type: :uuid
      t.references :request_status_type, null: false
      t.timestamps
      t.boolean :expiration_notice_to_patron, default: false
      t.boolean :expiration_notice_to_library, default: false
    end
  end

  def self.down
    drop_table :reserves
  end
end
