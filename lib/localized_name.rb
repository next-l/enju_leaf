module LocalizedName
  def localize(locale = I18n.locale.to_s)
    values = Hash[*self.strip.split("\n").map{|n| n.split(':', 2)}.flatten]
    name = values[locale] || self
    name.strip
  rescue ArgumentError
    self
  end
end

class String
  include LocalizedName
end
