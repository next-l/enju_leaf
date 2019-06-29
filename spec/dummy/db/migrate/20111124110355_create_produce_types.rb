class CreateProduceTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :produce_types do |t|
      t.string :name
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
