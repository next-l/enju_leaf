class CreateNdlBibIdRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :ndl_bib_id_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.references :manifestation, foreign_key: true, null: false

      t.timestamps
    end
  end
end
