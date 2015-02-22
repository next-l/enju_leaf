class CreateMessageRequests < ActiveRecord::Migration
  def self.up
    create_table :message_requests do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :message_template_id
      t.datetime :sent_at
      t.datetime :deleted_at
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :message_requests
  end
end
