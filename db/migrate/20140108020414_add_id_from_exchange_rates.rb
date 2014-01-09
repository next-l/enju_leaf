class AddIdFromExchangeRates < ActiveRecord::Migration
  def change
    add_column :exchange_rates, :currency_id, :integer
    add_column :exchange_rates, :rate, :decimal, precision:10, scale:2
    add_column :exchange_rates, :started_at, :timestamp
  end
end
