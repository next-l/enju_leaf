class CreateDoiRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :doi_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.string :display_body, null: false
      t.string :source
      t.jsonb :response, default: {}, null: false
      t.references :manifestation, foreign_key: true, null: false

      t.timestamps
    end
  end
end
