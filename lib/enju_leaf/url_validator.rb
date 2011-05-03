class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    url = ::Addressable::URI.parse(value)
    if url
      unless ['http', 'https'].include?(url.scheme)
        record.errors.add(attribute.to_sym)
      end
    end
  end
end
