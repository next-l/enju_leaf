class AddDoiToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :doi, :string
    add_index :manifestations, :doi
  end
end
