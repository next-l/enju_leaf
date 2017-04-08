class AddTaggingsCountToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :taggings_count, :integer, default: 0
  end
end
