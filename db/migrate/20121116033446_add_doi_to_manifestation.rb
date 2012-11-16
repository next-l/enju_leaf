class AddDoiToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :doi, :string
    add_index :manifestations, :doi
  end
end
