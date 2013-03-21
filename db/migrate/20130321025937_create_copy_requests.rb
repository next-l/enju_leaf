class CreateCopyRequests < ActiveRecord::Migration
  def change
    create_table :copy_requests do |t|
      t.integer :user_id, :null => false
      t.text :body
      t.timestamps
    end
  end
end
