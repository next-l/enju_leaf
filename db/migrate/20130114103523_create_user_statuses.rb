class CreateUserStatuses < ActiveRecord::Migration
  def change
    create_table :user_statuses do |t|
      t.string :name
      t.string :display_name
      t.integer :position

      t.timestamps
    end
  end
end
