class CreateEnjuNdlMigration < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :ndl_bib_id, :string
    add_index :manifestations, :ndl_bib_id, :unique => true
  end

  def self.down
    drop_column :manifestations, :ndl_bib_id
  end
end
