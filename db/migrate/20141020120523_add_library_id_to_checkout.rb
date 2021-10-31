class AddLibraryIdToCheckout < ActiveRecord::Migration[4.2]
  def change
    add_reference :checkouts, :library, index: true, foreign_key: true
  end
end
