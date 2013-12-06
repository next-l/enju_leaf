class CreateLibcheckNotfoundItems < ActiveRecord::Migration
  def self.up
    create_table :libcheck_notfound_items do |t|
      t.integer :item_id, :null => false
      t.string :item_identifier
      t.integer :status, :default => 0
    end
  end

  def self.down
    drop_table :libcheck_notfound_items
  end
end
