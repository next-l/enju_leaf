class CreateItemHasUseRestrictions < ActiveRecord::Migration
  def self.up
    create_table :item_has_use_restrictions do |t|
      t.references :item, null: false, index: true
      t.references :use_restriction, null: false, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :item_has_use_restrictions
  end
end
