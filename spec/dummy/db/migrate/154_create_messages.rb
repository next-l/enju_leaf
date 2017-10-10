class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages, force: true, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.datetime :read_at
      t.integer  :receiver_id
      t.integer :sender_id
      t.string   :subject, null: false
      t.text     :body
      t.integer :message_request_id
      t.uuid :parent_id

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :receiver_id
    add_index :messages, :message_request_id
    add_index :messages, :parent_id
  end
end
