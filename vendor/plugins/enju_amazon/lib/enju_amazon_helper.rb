module EnjuAmazonHelper
  def amazon_link(asin)
    return nil if asin.blank?
    "http://#{configatron.amazon.hostname}/dp/#{asin}"
  end
end
