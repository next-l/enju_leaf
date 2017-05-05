class AddPostponedAtToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :postponed_at, :datetime
  end
end
