class CreateUserRequestLogs < ActiveRecord::Migration
  def change
    create_table :user_request_logs do |t|
      t.integer :user_id
      t.string :controller
      t.string :action
      t.string :remote_ip
      t.text :data

      t.timestamps
    end
  end
end
