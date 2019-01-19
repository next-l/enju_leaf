class RenameManifestationPeriodicalToSerial < ActiveRecord::Migration[5.2]
  def up
    rename_column :manifestations, :periodical, :serial
  end

  def down
    rename_column :manifestations, :serial, :periodical
  end
end
