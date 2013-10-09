class CreateCheckedManifestations < ActiveRecord::Migration
  def change
    create_table :checked_manifestations do |t|
      t.integer :manifestation_id, :null => false
      t.integer :basket_id, :null => false
      t.timestamps
    end
  end
end
