class AddDeletedAtOnBaskets < ActiveRecord::Migration
  def self.up
    add_column :baskets, :deleted_at, :datetime
  end

  def self.down
    remove_column :baskets, :deleted_at
  end
end
