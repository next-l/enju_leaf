class AddNameToCreate < ActiveRecord::Migration[6.1]
  def change
    add_column :creates, :name, :text
    add_column :realizes, :name, :text
    add_column :produces, :name, :text
  end
end
