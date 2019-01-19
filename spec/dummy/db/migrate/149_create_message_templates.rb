class CreateMessageTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :message_templates do |t|
      t.string :status, null: false, index: {unique: true}
      t.text :title, null: false
      t.text :body, null: false
      t.integer :position
      t.string :locale, default: I18n.default_locale.to_s

      t.timestamps
    end
  end
end
