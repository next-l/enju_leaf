class CreateBookmarkStats < ActiveRecord::Migration
  def self.up
    create_table :bookmark_stats do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.text :note
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :bookmark_stats
  end
end
