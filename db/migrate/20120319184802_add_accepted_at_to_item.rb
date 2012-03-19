class AddAcceptedAtToItem < ActiveRecord::Migration
  def change
    add_column :items, :accepted_at, :datetime

  end
end
