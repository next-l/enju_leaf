class AddForeignKeyToBookstoreIdOnItems < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :items, :bookstores
    add_foreign_key :items, :budget_types
    add_foreign_key :items, :checkout_types
    add_foreign_key :items, :circulation_statuses
    add_foreign_key :items, :shelves
  end
end
