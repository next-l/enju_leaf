class CreateManifestationReserveStats < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestation_reserve_stats do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.text :note

      t.timestamps
    end
  end
end
