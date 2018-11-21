class AddIsilToLibrary < ActiveRecord::Migration[5.1]
  def change
    add_column :libraries, :isil, :string, index: {unique: true}
  end
end
