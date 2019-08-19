class CreatePeriodicalAndManifestations < ActiveRecord::Migration[5.2]
  def change
    create_table :periodical_and_manifestations do |t|
      t.references :periodical, foreign_key: true, null: false
      t.references :manifestation, foreign_key: true, null: false
      t.boolean :periodical_master, default: false, null: false, index: {where: 'periodical_master IS true', unique: true}

      t.timestamps
    end
  end
end
