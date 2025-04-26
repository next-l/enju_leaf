class CreateNdlBibIdRecords < ActiveRecord::Migration[5.2]
  def up
    create_table :ndl_bib_id_records, if_not_exists: true do |t|
      t.string :body, index: {unique: true}, null: false
      t.references :manifestation, foreign_key: true, null: false

      t.timestamps
    end
  end

  def down
    drop_table :ndl_bib_id_records
  end
end
