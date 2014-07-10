class AddRetainedAtToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :retained_at, :datetime
  end
end
