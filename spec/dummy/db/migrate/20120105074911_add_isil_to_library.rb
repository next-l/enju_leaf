class AddIsilToLibrary < ActiveRecord::Migration[5.2]
  def change
    add_column :libraries, :isil, :string
  end
end
