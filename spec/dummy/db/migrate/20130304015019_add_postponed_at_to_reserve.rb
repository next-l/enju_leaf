class AddPostponedAtToReserve < ActiveRecord::Migration[5.0]
  def change
    add_column :reserves, :postponed_at, :datetime
  end
end
