# This migration comes from acts_as_taggable_on_engine (originally 1)
if ActiveRecord.gem_version >= Gem::Version.new('5.0')
  class ActsAsTaggableOnMigration < ActiveRecord::Migration[4.2]; end
else
  class ActsAsTaggableOnMigration < ActiveRecord::Migration; end
end
ActsAsTaggableOnMigration.class_eval do
  def up
    create_table :tags, if_not_exists: true do |t|
      t.string :name
    end

    create_table :taggings, if_not_exists: true do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, polymorphic: true
      t.references :tagger, polymorphic: true

      # Limit is created to prevent MySQL error on index
      # length for MyISAM table type: http://bit.ly/vgW2Ql
      t.string :context, limit: 128

      t.datetime :created_at
    end

    add_index :taggings, :tag_id, if_not_exists: true
    add_index :taggings, [:taggable_id, :taggable_type, :context], if_not_exists: true
  end

  def down
    drop_table :taggings
    drop_table :tags
  end
end
