class CreateEnjuTrunkCirculationCheckoutHistories < ActiveRecord::Migration
  def change
    create_table :checkout_histories do |t|
      t.integer :operation
      t.integer :item_id
      t.integer :manifestation_id
      t.integer :librarian_id
      t.integer :user_id
      t.integer :checkout_id
      t.integer :checkin_id
      t.integer :reserve_id
      t.timestamps
    end
  end
end
