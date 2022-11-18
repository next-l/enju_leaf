class ChangeColumnColorsLibraryGroupIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    [
      :colors,
      :libraries,
      :library_group_translations,
      :news_feeds
    ].each do |table|
      change_column table, :library_group_id, :bigint
    end
  end
end
