class RemovePairFromExchangeRates < ActiveRecord::Migration
  def up
    remove_column :exchange_rates, :pair1
    remove_column :exchange_rates, :pair2
    remove_column :exchange_rates, :rate
    remove_column :exchange_rates, :start_date
    remove_column :exchange_rates, :end_date
  end

  def down
    add_column :exchange_rates, :end_date, :datatime
    add_column :exchange_rates, :start_date, :datatime
    add_column :exchange_rates, :rate, :decimal
    add_column :exchange_rates, :pair2, :string
    add_column :exchange_rates, :pair1, :string
  end
end
