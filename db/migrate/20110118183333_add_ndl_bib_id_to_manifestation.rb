class AddNdlBibIdToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :ndl_bib_id, :string
    add_index :manifestations, :ndl_bib_id
  end

  def self.down
    remove_column :manifestations, :ndl_bib_id
  end
end
