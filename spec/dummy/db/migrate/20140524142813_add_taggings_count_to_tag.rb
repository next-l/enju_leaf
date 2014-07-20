class AddTaggingsCountToTag < ActiveRecord::Migration
  def change
    add_column :tags, :taggings_count, :integer, default: 0
  end
end
