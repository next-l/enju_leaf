class AddTaggingsCountToTag < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :taggings_count, :integer, default: 0
  end
end
