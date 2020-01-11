class CreateCreateTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :create_types do |t|
      t.string :name
      t.text :display_name
      t.text :note, comment: '備考'
      t.integer :position

      t.timestamps
    end
  end
end
