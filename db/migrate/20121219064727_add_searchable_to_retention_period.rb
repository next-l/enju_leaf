class AddSearchableToRetentionPeriod < ActiveRecord::Migration
  def change
    add_column :retention_periods, :non_searchable, :boolean, :default => false, :null => true
  end
end
