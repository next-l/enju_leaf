class CreateCheckedItems < ActiveRecord::Migration
  def self.up
    create_table :checked_items do |t|
      t.references :item, null: false, index: true
      t.references :basket, null: false, index: true
      t.datetime :due_date, null: false

      t.timestamps
    end
  end

  def self.down
    drop_table :checked_items
  end
end
