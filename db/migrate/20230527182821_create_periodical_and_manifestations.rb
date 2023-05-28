class CreatePeriodicalAndManifestations < ActiveRecord::Migration[6.1]
  def change
    create_table :periodical_and_manifestations do |t|
      t.references :periodical, null: false, foreign_key: true
      t.references :manifestation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
