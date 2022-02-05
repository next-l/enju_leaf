module LocalizedName
  def localize(locale = I18n.locale)
    string = YAML.load(self)
    if string.is_a?(Hash) && string[locale.to_s]
      return string[locale.to_s]
    end
    self
  rescue NoMethodError
    self
  end
end
