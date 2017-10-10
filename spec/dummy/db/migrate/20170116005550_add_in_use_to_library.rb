class AddInUseToLibrary < ActiveRecord::Migration[5.1]
  def change
    add_column :libraries, :in_use, :boolean, null: false, default: false
  end
end
