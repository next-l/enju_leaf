class CreateBookbindings < ActiveRecord::Migration
  def self.up
    create_table :bookbindings do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :bookbindings
  end
end
