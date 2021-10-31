class CreateManifestationCustomProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :manifestation_custom_properties do |t|
      t.string :name, null: false, comment: 'ラベル名', index: {unique: true}
      t.text :display_name, null: false, comment: '表示名'
      t.text :note, comment: '備考'
      t.integer :position, default: 1, null: false

      t.timestamps
    end
  end
end
