class AddColumnNoteToDepartment < ActiveRecord::Migration
  def change
    add_column :departments, :note, :text
  end
end
