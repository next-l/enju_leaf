class CreateExemplifies < ActiveRecord::Migration
  def change
    create_table :exemplifies do |t|
      t.references :manifestation, foreign_key: true, null: false, type: :uuid
      t.references :item, foreign_key: true, index: {unique: true}, null: false, type: :uuid
      t.integer :position

      t.timestamps
    end
  end
end
