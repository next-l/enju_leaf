class BookmarkStatHasManifestation < ActiveRecord::Base
  belongs_to :bookmark_stat
  belongs_to :manifestation, :class_name => 'Manifestation'

  validates_uniqueness_of :manifestation_id, :scope => :bookmark_stat_id

  def self.per_page
    10
  end
end
