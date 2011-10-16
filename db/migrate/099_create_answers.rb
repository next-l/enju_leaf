class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.integer :user_id, :null => false
      t.integer :question_id, :null => false
      t.text :body
      t.timestamps
      t.datetime :deleted_at
      t.boolean :shared, :default => true, :null => false
      t.string :state
    end
    add_index :answers, :user_id
    add_index :answers, :question_id
  end

  def self.down
    drop_table :answers
  end
end
