class CreateIssnRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :issn_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.string :issn_type
      t.string :source

      t.timestamps
    end
  end
end
