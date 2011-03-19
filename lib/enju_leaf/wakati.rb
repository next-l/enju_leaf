#require 'MeCab'
module Wakati
  def wakati
    m = MeCab::Tagger.new("-O wakati")
    m.parse(self).strip
  rescue
    self
  end

  def yomi
    m = MeCab::Tagger.new("-O yomi")
    m.parse(self).strip
  rescue
    self
  end
end

class String
  include Wakati
end
