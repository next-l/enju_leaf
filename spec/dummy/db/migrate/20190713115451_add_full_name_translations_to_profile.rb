class AddFullNameTranslationsToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :full_name_translations, :jsonb, default: {}, null: false
  end
end
