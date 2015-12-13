class AddTranslationTableToLibraryGroup < ActiveRecord::Migration
  def up
    LibraryGroup.create_translation_table!({
      login_banner: :text
    }, {
      migrate_data: true
    })
  end

  def down
    LibraryGroup.drop_translation_table! migrate_data: true
  end
end
