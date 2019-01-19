class AddPostponedAtToReserve < ActiveRecord::Migration[5.2]
  def change
    add_column :reserves, :postponed_at, :datetime
  end
end
