class CreateBookmarkStats < ActiveRecord::Migration[5.0]
  def change
    create_table :bookmark_stats do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :started_at
      t.datetime :completed_at
      t.text :note

      t.timestamps
    end
  end
end
