class CreateFormOfWorks < ActiveRecord::Migration
  def self.up
    create_table :form_of_works do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :form_of_works
  end
end
