class AddShelfIdToCheckout < ActiveRecord::Migration[5.2]
  def change
    add_reference :checkouts, :shelf, index: true, foreign_key: true
  end
end
