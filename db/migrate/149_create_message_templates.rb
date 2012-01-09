class CreateMessageTemplates < ActiveRecord::Migration
  def change
    create_table :message_templates do |t|
      t.string :status, :null => false
      t.text :title, :null => false
      #t.text :subject
      t.text :body, :null => false
      t.integer :position

      t.timestamps
    end
    add_index :message_templates, :status, :unique => true
  end
end
