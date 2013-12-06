class AddUnableToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :unable, :boolean
  end

  def self.down
    remove_column :users, :unable
  end
end
