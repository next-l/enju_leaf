class FamilyAddTable < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.integer :owner_id
      t.integer :user_id

      t.timestamps
    end    
  end

  def self.down
    drop_table :families
  end
end
