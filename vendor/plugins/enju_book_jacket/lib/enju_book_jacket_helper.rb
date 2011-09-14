module EnjuBookJacketHelper
  def screenshot_tag(manifestation, generator = configatron.book_jacket.source)
    return nil unless manifestation.try(:access_address)
    case generator
    when :mozshot
      link_to image_tag("http://mozshot.nemui.org/shot?#{manifestation.access_address}", :width => 128, :height => 128, :alt => manifestation.original_title, :border => 0, :itemprop => 'image'), manifestation.access_address
    when :simpleapi
      link_to image_tag("http://img.simpleapi.net/small/#{manifestation.access_address}", :width => 128, :height => 128, :alt => manifestation.original_title, :border => 0, :itemprop => 'image'), manifestation.access_address
    when :heartrails
      link_to image_tag("http://capture.heartrails.com/medium?#{manifestation.access_address}", :width => 120, :height => 90, :alt => manifestation.original_title, :border => 0, :itemprop => 'image'), manifestation.access_address
    when :thumbalizr
      link_to image_tag("http://api.thumbalizr.com/?url=#{manifestation.access_address}&width=128", :width => 128, :height => 144, :alt => manifestation.original_title, :border => 0, :itemprop => 'image'), manifestation.access_address
    end
  end

  def book_jacket_tag(manifestation, generator = configatron.book_jacket.source)
    return nil unless manifestation
    case generator
    when :amazon
      return nil unless configatron.amazon.hostname
      book_jacket = manifestation.amazon_book_jacket
      if book_jacket
        link_to image_tag(book_jacket[:url], :width => book_jacket[:width], :height => book_jacket[:height], :alt => manifestation.original_title, :class => 'book_jacket', :itemprop => 'image'), "http://#{configatron.amazon.hostname}/dp/#{book_jacket[:asin]}"
      end
    when :google
      render :partial => 'manifestations/google_book_thumbnail', :locals => {:manifestation => manifestation}
    end
  end

  def amazon_link(asin)
    return nil if asin.blank?
    "http://#{configatron.amazon.hostname}/dp/#{asin}"
  end
end
