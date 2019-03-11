class CreateSubscribes < ActiveRecord::Migration[5.2]
  def change
    create_table :subscribes do |t|
      t.references :subscription, foreign_key: true, null: false, type: :uuid
      t.references :work, null: false, type: :uuid
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false

      t.timestamps
    end
  end
end
