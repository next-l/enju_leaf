module LocalizedName
  def localize(locale = I18n.locale)
    string = YAML.load(self)[locale.to_s]
    if string
      string
    else
      self
    end
  rescue NoMethodError
    self
  end
end

class String
  include LocalizedName
end
