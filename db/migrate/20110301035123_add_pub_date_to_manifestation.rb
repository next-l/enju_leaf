class AddPubDateToManifestation < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestations, :pub_date, :string
  end

  def down
    remove_column :manifestations, :pub_date
  end
end
