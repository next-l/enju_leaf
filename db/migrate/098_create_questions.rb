class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.integer :user_id, :null => false
      t.text :body
      t.boolean :shared, :default => true, :null => false
      t.integer :answers_count, :default => 0, :null => false
      t.timestamps
      t.datetime :deleted_at
      t.string :state
    end
    add_index :questions, :user_id
  end

  def self.down
    drop_table :questions
  end
end
