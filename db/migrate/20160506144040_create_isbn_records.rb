class CreateIsbnRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :isbn_records, comment: 'ISBN' do |t|
      t.string :body, null: false, comment: 'ISBN'

      t.timestamps
    end

    add_index :isbn_records, :body
  end
end
