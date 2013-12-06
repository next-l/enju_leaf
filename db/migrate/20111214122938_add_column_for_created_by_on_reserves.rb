class AddColumnForCreatedByOnReserves < ActiveRecord::Migration
  def self.up
    add_column :reserves, :created_by, :integer
  end

  def self.down
    remove_column :reserves, :created_by
  end
end
