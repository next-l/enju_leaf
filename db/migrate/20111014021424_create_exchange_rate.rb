class CreateExchangeRate < ActiveRecord::Migration
  def self.up
    create_table :exchange_rates do |t|
      t.string :pair1, :null => false 
      t.string :pair2, :null => false 
      t.decimal :rate, :null => false 
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end

  def self.down
    drop_table :exchange_rates
  end
end
