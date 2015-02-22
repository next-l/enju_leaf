class RemoveExpireDateFromReserve < ActiveRecord::Migration
  def self.up
    remove_column :reserves, :expire_date
  end

  def self.down
    add_column :reserves, :expire_date, :string
  end
end
