class FamilyAddTable < ActiveRecord::Migration
  def self.up
    create_table :families do |t|
      t.timestamps
    end    
  end

  def self.down
    drop_table :families
  end
end
