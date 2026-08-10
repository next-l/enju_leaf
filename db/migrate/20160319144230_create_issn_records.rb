class CreateIssnRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :issn_records, comment: 'ISSN' do |t|
      t.string :body, null: false, comment: 'ISSN'

      t.timestamps
    end

    add_index :issn_records, :body, unique: true
  end
end
