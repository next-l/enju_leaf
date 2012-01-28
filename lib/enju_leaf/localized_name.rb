module LocalizedName
  def localize(locale = I18n.locale)
    string = YAML.load(self)
    if string.is_a?(Hash) and string[locale.to_s]
      return string[locale.to_s]
    end
    self
  rescue NoMethodError
    self
  end
end

class String
  include LocalizedName
end
