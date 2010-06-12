module EnjuAmazon
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_amazon
      include EnjuAmazon::InstanceMethods
    end
  end

  module InstanceMethods
    def amazon
      if AMAZON_ACCESS_KEY == 'REPLACE_WITH_YOUR_AMAZON_KEY'
        Rails.logger.error "Amazon access key is not set"
        return nil
      end
      unless self.isbn.blank?
        response = access_amazon_proxy
      end
    end

    def access_amazon
      if AMAZON_ACCESS_KEY == 'REPLACE_WITH_YOUR_AMAZON_KEY'
        Rails.logger.error "Amazon access key is not set"
        return nil
      end
      unless self.isbn.blank?
        timestamp = CGI.escape(Time.now.utc.iso8601)
        query = [
          "AWSAccessKeyId=#{AMAZON_ACCESS_KEY}",
          "IdType=ISBN",
          "ItemId=#{self.isbn}",
          "Operation=ItemLookup",
          "ResponseGroup=Images%2CReviews",
          "SearchIndex=Books",
          "Service=AWSECommerceService",
          "Timestamp=#{timestamp}",
          "Version=2009-01-06"
          ].join("&")
        message = ["GET", AMAZON_AWS_HOSTNAME, "/onca/xml", query].join("\n")
        hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, AMAZON_SECRET_ACCESS_KEY, message)
        encoded_hash = CGI.escape(Base64.encode64(hash).strip)
        amazon_url = "http://#{AMAZON_AWS_HOSTNAME}/onca/xml?#{query}&Signature=#{encoded_hash}"

        open(amazon_url) do |f|
          f.read
        end
      end
    end

    def amazon_book_jacket
      response = amazon
      doc = Nokogiri::XML(response)
      bookjacket = {}
      bookjacket['url'] = doc.at('Item/MediumImage/URL').inner_text
      bookjacket['width'] = doc.at('Item/MediumImage/Width').inner_text.to_i
      bookjacket['height'] = doc.at('Item/MediumImage/Height').inner_text.to_i
      bookjacket['asin'] = doc.at('Item/ASIN').inner_text

      if bookjacket['url'].blank?
        raise "Can't get bookjacket"
      end
      return bookjacket

    rescue
      bookjacket = {'url' => 'unknown_resource.png', 'width' => '100', 'height' => '100'}
    end

    def amazon_customer_reviews
      if self.amazon
        doc = Nokogiri::XML(self.amazon)
        reviews = []
        doc.xpath('//xmlns:Review').each do |item|
          r = {}
          r[:date] = item.at('Date').inner_text
          r[:summary] = item.at('Summary').inner_text
          r[:content] = item.at('Content').inner_text
          reviews << r
        end
        reviews
      else
        []
      end
    end

    def asin
      if self.isbn.length == 10
        self.isbn
      elsif self.isbn.length == 13
        ISBN_Tools.isbn13_to_isbn10(self.isbn)
      end
    end

    private
    def access_amazon_proxy
      Rails.cache.fetch("manifestation_amazon_response_#{self.id}"){self.access_amazon}
    end
    
  end
end
