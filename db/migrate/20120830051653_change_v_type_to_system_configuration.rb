class ChangeVTypeToSystemConfiguration < ActiveRecord::Migration
  def up
   change_column :system_configurations , :v, :text
  end

  def down
   change_column :system_configurations , :v, :string
  end
end
