class CreateKeywordCounts < ActiveRecord::Migration
  def change
    create_table :keyword_counts do |t|
      t.datetime :date
      t.text :keyword
      t.integer :count

      t.timestamps
    end
  end
end
