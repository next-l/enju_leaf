class CreatePeriodicals < ActiveRecord::Migration[6.1]
  def change
    create_table :periodicals do |t|
      t.text :original_title, null: false
      t.references :manifestation, null: false, foreign_key: true
      t.references :frequency, null: false, foreign_key: true

      t.timestamps
    end
  end
end
