class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value =~ /\Ahttps?:\/\/[^\n]+\z/i
      url = ::Addressable::URI.parse(value)
      unless ['http', 'https'].include?(url.scheme)
        record.errors.add(attribute.to_sym)
      end
    else
      record.errors.add(attribute.to_sym)
    end
  end
end
