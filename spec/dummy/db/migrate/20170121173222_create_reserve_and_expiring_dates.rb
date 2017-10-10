class CreateReserveAndExpiringDates < ActiveRecord::Migration[5.1]
  def change
    create_table :reserve_and_expiring_dates do |t|
      t.references :reserve, foreign_key: true, null: false, type: :uuid
      t.date :expire_on, null: false

      t.timestamps
    end
  end
end
