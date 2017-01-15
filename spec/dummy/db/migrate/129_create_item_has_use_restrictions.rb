class CreateItemHasUseRestrictions < ActiveRecord::Migration[5.0]
  def change
    create_table :item_has_use_restrictions do |t|
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.references :use_restriction, null: false, foreign_key: true

      t.timestamps
    end
  end
end
