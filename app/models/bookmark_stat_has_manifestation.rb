class BookmarkStatHasManifestation < ApplicationRecord
  belongs_to :bookmark_stat
  belongs_to :manifestation

  validates_uniqueness_of :manifestation_id, scope: :bookmark_stat_id

  paginates_per 10
end

# == Schema Information
#
# Table name: bookmark_stat_has_manifestations
#
#  id               :bigint           not null, primary key
#  bookmark_stat_id :integer          not null
#  manifestation_id :bigint           not null
#  bookmarks_count  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
