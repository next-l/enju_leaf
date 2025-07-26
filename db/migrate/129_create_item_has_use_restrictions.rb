class CreateItemHasUseRestrictions < ActiveRecord::Migration[4.2]
  def up
    create_table :item_has_use_restrictions do |t|
      t.references :item, index: true, foreign_key: true, null: false
      t.references :use_restriction, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end

  def down
    drop_table :item_has_use_restrictions
  end
end
