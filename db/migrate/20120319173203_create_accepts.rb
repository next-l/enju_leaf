class CreateAccepts < ActiveRecord::Migration
  def change
    create_table :accepts do |t|
      t.integer :item_id

      t.timestamps
    end

    add_index :accepts, :item_id
  end
end
