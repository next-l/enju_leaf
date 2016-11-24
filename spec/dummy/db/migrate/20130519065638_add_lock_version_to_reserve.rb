class AddLockVersionToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :lock_version, :integer, default: 0, null: false
  end
end
