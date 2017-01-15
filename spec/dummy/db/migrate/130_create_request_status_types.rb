class CreateRequestStatusTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :request_status_types do |t|
      t.string :name, index: {unique: true}, null: false
      t.jsonb :display_name_translations
      t.text :note
      t.integer :position

      t.timestamps
    end
  end
end
