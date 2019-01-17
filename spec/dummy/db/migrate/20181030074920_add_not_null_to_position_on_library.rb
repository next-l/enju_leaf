class AddNotNullToPositionOnLibrary < ActiveRecord::Migration[5.2]
  def change
    change_column :libraries, :position, :integer,  null: false, default: 1
    change_column :shelves, :position, :integer,  null: false, default: 1
    change_column :library_groups, :position, :integer,  null: false, default: 1
    change_column :user_groups, :position, :integer,  null: false, default: 1
    change_column :bookstores, :position, :integer,  null: false, default: 1
    change_column :budget_types, :position, :integer,  null: false, default: 1
    change_column :colors, :position, :integer,  null: false, default: 1
    change_column :request_types, :position, :integer,  null: false, default: 1
    change_column :request_status_types, :position, :integer,  null: false, default: 1
    change_column :search_engines, :position, :integer,  null: false, default: 1
  end
end
