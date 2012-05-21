class AddOnlineIsbnToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :online_isbn, :string
  end
end
