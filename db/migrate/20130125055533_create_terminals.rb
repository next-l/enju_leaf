class CreateTerminals < ActiveRecord::Migration
  def change
    create_table :terminals do |t|
      t.string :ipaddr
      t.string :name
      t.string :comment
      t.boolean :checkouts_autoprint
      t.boolean :reserve_autoprint
      t.boolean :manifestation_autoprint

      t.timestamps
    end
  end
end
