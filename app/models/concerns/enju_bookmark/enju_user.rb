module EnjuBookmark
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :bookmarks, dependent: :destroy
      acts_as_tagger
    end

    def owned_tags_by_solr
      bookmark_ids = bookmarks.collect(&:id)
      if bookmark_ids.empty?
        []
      else
        Tag.bookmarked(bookmark_ids)
      end
    end
  end
end
