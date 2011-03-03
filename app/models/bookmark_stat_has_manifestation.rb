class BookmarkStatHasManifestation < ActiveRecord::Base
  belongs_to :bookmark_stat
  belongs_to :manifestation, :class_name => 'Manifestation'

  validates_uniqueness_of :manifestation_id, :scope => :bookmark_stat_id
  validates_presence_of :bookmark_stat_id, :manifestation_id

  def self.per_page
    10
  end
end
