module PageHelper
  def msie_acceralator
    render :partial => 'page/msie_acceralator'
  end

  def book_jacket_source_link
    case Setting.book_jacket.source
    when :google
      link_to "Google Books", "http://books.google.com/"
    when :amazon
      link_to "Amazon Web Services", "http://aws.amazon.com/"
    end
  end

  def screenshot_generator_link
    case Setting.screenshot.generator
    when :mozshot
      link_to "MozShot", "http://mozshot.nemui.org/"
    when :simpleapi
      link_to "SimpleAPI", "http://img.simpleapi.net/"
    when :heartrails
      link_to "HeartRails Capture", "http://capture.heartrails.com/"
    when :thumbalizr
      link_to "thumbalizr", "http://www.thumbalizr.com/"
    end
  end
end
