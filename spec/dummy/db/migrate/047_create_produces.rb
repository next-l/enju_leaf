class CreateProduces < ActiveRecord::Migration[5.2]
  def change
    create_table :produces do |t|
      t.references :agent, foreign_key: true, null: false
      t.references :manifestation, foreign_key: true, null: false
      t.integer :position
      t.timestamps
    end
  end
end
