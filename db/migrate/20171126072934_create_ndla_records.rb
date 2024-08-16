class CreateNdlaRecords < ActiveRecord::Migration[5.2]
  def up
    create_table :ndla_records, if_not_exists: true do |t|
      t.references :agent, foreign_key: true
      t.string :body, null: false, index: {unique: true}

      t.timestamps
    end
  end

  def down
    drop_table :ndla_records
  end
end
