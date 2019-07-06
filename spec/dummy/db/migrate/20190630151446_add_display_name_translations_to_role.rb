class AddDisplayNameTranslationsToRole < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :display_name_translations, :jsonb, default: {}, null: false
  end
end
