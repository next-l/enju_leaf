class AddAcceptTypeIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :accept_type_id, :integer
  end
end
