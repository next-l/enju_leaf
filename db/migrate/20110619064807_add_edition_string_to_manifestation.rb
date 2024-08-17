class AddEditionStringToManifestation < ActiveRecord::Migration[4.2]
  def up
    add_column :manifestations, :edition_string, :string
  end

  def down
    remove_column :manifestations, :edition_string
  end
end
