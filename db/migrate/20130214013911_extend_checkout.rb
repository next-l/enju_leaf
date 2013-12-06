class ExtendCheckout < ActiveRecord::Migration
  def up
    add_column :checkouts, :available_for_extend, :boolean
  end

  def down
    remove_column :checkouts, :available_for_extend
  end
end
