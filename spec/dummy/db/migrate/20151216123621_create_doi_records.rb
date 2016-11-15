class CreateDoiRecords < ActiveRecord::Migration
  def change
    create_table :doi_records do |t|
      t.string :body, index: true, null: false
      t.string :registration_agency
      t.references :manifestation, index: true, null: false
      t.string :source

      t.timestamps null: false
    end
  end
end
