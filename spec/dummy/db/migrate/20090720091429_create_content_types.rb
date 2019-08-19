class CreateContentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :content_types do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
