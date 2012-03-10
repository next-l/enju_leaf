class AddIsilToLibrary < ActiveRecord::Migration
  def change
    add_column :libraries, :isil, :string
  end
end
