class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.datetime :read_at
      t.references :sender, index: true
      t.references :receiver, index: true
      t.string   :subject, null: false
      t.text     :body
      t.references :message_request, index: true
      t.references :parent, foreign_key: {to_table: :messages}

      t.timestamps
    end
  end
end
