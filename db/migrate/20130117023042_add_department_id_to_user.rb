class AddDepartmentIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :department_id, :integer
  end
end
