class CreateAnswers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :answers do |t|
      t.integer :user_id, :null => false
      t.integer :question_id, :null => false
      t.text :body
      t.timestamps
      t.datetime :deleted_at
      t.boolean :shared, :default => true, :null => false
      t.string :state
      t.text :item_identifier_list
      t.text :url_list
    end
    add_index :answers, :user_id
    add_index :answers, :question_id
  end

  def self.down
    drop_table :answers
  end
end
