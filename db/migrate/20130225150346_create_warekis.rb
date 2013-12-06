class CreateWarekis < ActiveRecord::Migration
  def change
    create_table :warekis do |t|
      t.string :display_name
      t.string :short_name
      t.integer :year_from
      t.integer :year_to
      t.text :note

      t.timestamps
    end
  end
end
