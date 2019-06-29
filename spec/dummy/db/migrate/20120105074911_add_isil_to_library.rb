class AddIsilToLibrary < ActiveRecord::Migration[4.2]
  def change
    add_column :libraries, :isil, :string
  end
end
