class CreateMessageRequests < ActiveRecord::Migration[5.2]
  def self.up
    create_table :message_requests do |t|
      t.references :sender
      t.references :receiver
      t.references :message_template
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
