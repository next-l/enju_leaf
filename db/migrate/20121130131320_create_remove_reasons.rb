class CreateRemoveReasons < ActiveRecord::Migration
  def change
    create_table :remove_reasons do |t|
      t.string :name
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
