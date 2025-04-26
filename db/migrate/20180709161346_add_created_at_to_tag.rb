class AddCreatedAtToTag < ActiveRecord::Migration[5.1]
  def up
    add_column :tags, :created_at, :datetime, if_not_exists: true
    add_column :tags, :updated_at, :datetime, if_not_exists: true
  end

  def down
    remove_column :tags, :created_at
    remove_column :tags, :updated_at
  end
end
