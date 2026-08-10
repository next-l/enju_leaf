class RemovePrimaryFromIdentifiers < ActiveRecord::Migration[7.1]
  def change
    remove_column :identifiers, :primary, :boolean
  end
end
