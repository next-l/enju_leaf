class CreateThemeHasManifestation < ActiveRecord::Migration
  def change
    create_table :theme_has_manifestations do |t|
      t.integer :theme_id, null: false, :default => 0
      t.integer :manifestation_id, null: false, :default => 0
      t.integer :position, null: false, :default => 0

      t.timestamps
    end
  end
end
