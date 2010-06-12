module EnjuAmazonHelper
  def amazon_link(asin)
    return nil if asin.blank?
    "http://#{AMAZON_HOSTNAME}/dp/#{asin}"
  end
end
