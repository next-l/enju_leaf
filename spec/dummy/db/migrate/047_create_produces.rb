class CreateProduces < ActiveRecord::Migration[5.2]
  def change
    create_table :produces do |t|
      t.references :agent, null: false
      t.references :manifestation, null: false
      t.integer :position
      t.timestamps
    end
  end
end
