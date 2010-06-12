class CreateBaskets < ActiveRecord::Migration
  def self.up
    create_table :baskets do |t|
      t.integer :user_id
      t.text :note
      t.string :type
      t.integer :lock_version, :default => 0, :null => false

      t.timestamps
    end
    add_index :baskets, :user_id
    add_index :baskets, :type
  end

  def self.down
    drop_table :baskets
  end
end
