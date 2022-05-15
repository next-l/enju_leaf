module EnjuBookmark
  module EnjuManifestation
    extend ActiveSupport::Concern

    included do
      has_many :bookmarks, dependent: :destroy, foreign_key: :manifestation_id, inverse_of: :manifestation
      has_many :users, through: :bookmarks

      searchable do
        string :tag, multiple: true do
          bookmarks.map{|bookmark| bookmark.tag_list}.flatten
        end
        text :tag do
          bookmarks.map{|bookmark| bookmark.tag_list}.flatten
        end
      end
    end

    def bookmarked?(user)
      return true if user.bookmarks.where(url: url).first
      false
    end

    def tags
      bookmarks.map{|bookmark| bookmark.tags}.flatten
    end
  end
end
