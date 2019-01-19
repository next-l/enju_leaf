class AddPubDateToManifestation < ActiveRecord::Migration[5.2]
  def self.up
    add_column :manifestations, :pub_date, :string
  end

  def self.down
    remove_column :manifestations, :pub_date
  end
end
