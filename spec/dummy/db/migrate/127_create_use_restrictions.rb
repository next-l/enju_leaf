class CreateUseRestrictions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :use_restrictions do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :use_restrictions
  end
end
