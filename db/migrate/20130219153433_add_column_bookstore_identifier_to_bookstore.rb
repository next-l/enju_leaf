class AddColumnBookstoreIdentifierToBookstore < ActiveRecord::Migration
  def change
    add_column :bookstores, :bookstore_identifier, :string
  end
end
