class CreateEnjuTrunkCirculationCheckoutHistories < ActiveRecord::Migration
  def change
    create_table :enju_trunk_circulation_checkout_histories do |t|
      t.integer :operation
      t.string :object
      t.integer :librarian_id
      t.integer :user_id
      t.timestamps
    end
  end
end
