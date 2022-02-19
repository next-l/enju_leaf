class AddAnswerFeedTokenToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :answer_feed_token, :string
    add_index :users, :answer_feed_token, :unique => true
  end
end
