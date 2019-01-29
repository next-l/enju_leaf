class CreateOwns < ActiveRecord::Migration[5.2]
  def change
    create_table :owns do |t|
      t.references :agent, null: false, type: :uuid
      t.references :item, null: false, type: :uuid
      t.integer :position
      t.timestamps
    end
  end
end
