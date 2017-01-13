class CreateDoiRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :doi_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.string :registration_agency
      t.references :manifestation, foreign_key: true, type: :uuid
      t.string :source

      t.timestamps
    end
  end
end
