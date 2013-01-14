class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.string :display_name
      t.string :short_name
      t.integer :position

      t.timestamps
    end
    add_index :departments, :name
    add_index :departments, :position
  end

end
