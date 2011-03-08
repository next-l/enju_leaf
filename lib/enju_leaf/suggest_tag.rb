module SuggestTag
  def suggest_tags
    tags = []
    threshold = (self.strip.split(//).size * 0.2).round
    Bookmark.tag_counts(:limit => 100).each do |t|
      distance = Text::Levenshtein.distance(t.name, self)
      tags << t if distance <= threshold
    end
    tags
  end
end

class String
  include SuggestTag
end
