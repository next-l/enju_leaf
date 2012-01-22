module LocalizedName
  def localize(locale = I18n.locale.to_s)
    string = YAML.load(self)[locale]
    if string
      string
    else
      self
    end
  end
end

class String
  include LocalizedName
end
