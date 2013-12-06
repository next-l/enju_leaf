class CreateClassmarks < ActiveRecord::Migration
  def change
    create_table :classmarks do |t|
      t.string :name
      t.string :display_name

      t.timestamps
    end
    add_index :classmarks, :name
  end
end
