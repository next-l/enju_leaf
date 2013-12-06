class AddDepartmentIdToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :department_id, :integer
  end
end
