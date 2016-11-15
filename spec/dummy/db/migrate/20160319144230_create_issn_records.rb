class CreateIssnRecords < ActiveRecord::Migration
  def change
    create_table :issn_records do |t|
      t.string :body, index: true, null: false
      t.string :issn_type
      t.string :source
      t.integer :manifestation_id, index: true

      t.timestamps null: false
    end
  end
end
