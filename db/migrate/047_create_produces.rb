class CreateProduces < ActiveRecord::Migration
  def self.up
    create_table :produces do |t|
      t.references :patron, :null => false
      t.references :manifestation, :null => false
      t.integer :position
      t.string :type
      t.timestamps
    end
    add_index :produces, :patron_id
    add_index :produces, :manifestation_id
    add_index :produces, :type
  end

  def self.down
    drop_table :produces
  end
end
