module EnjuManifestationViewer
  module BookJacketHelper
    def book_jacket(manifestation)
      if manifestation.picture_files.exists?
        link = ''
        manifestation.picture_files.each_with_index do |picture_file, i|
          next unless picture_file.attachment.attached?

          link += if i == 0
                    link_to(show_image(picture_file, size: :thumb), rails_blob_url(picture_file.attachment), rel: "manifestation_#{manifestation.id}")
                  else
                    content_tag :span, style: "display: none" do
                      link_to(show_image(picture_file, size: :thumb), rails_blob_url(picture_file.attachment), rel: "manifestation_#{manifestation.id}")
                    end
                  end
        end
        return link.html_safe
      else
        link = book_jacket_tag(manifestation)
        link ||= screenshot_tag(manifestation)
      end

      link ||= link_to image_tag('unknown_resource.png', width: '100', height: '100', alt: '*', itemprop: 'image'), manifestation
      link
    end

    def screenshot_tag(manifestation, generator = LibraryGroup.site_config.screenshot_generator)
      return nil unless manifestation.try(:access_address)

      case generator
      when "mozshot"
        link_to image_tag("https://blinky.nemui.org/shot?#{manifestation.access_address}", width: 128, height: 128, alt: manifestation.original_title, border: 0, itemprop: 'image'), manifestation.access_address
      when "simpleapi"
        link_to image_tag("http://img.simpleapi.net/small/#{manifestation.access_address}", width: 128, height: 128, alt: manifestation.original_title, border: 0, itemprop: 'image'), manifestation.access_address
      when "heartrails"
        link_to image_tag("http://capture.heartrails.com/medium?#{manifestation.access_address}", width: 120, height: 90, alt: manifestation.original_title, border: 0, itemprop: 'image'), manifestation.access_address
      when "thumbalizr"
        link_to image_tag("http://api.thumbalizr.com/?url=#{manifestation.access_address}&width=128", width: 128, height: 144, alt: manifestation.original_title, border: 0, itemprop: 'image'), manifestation.access_address
      end
    end

    def book_jacket_tag(manifestation, generator = LibraryGroup.site_config.book_jacket_source)
      return nil unless manifestation

      case generator
      when "amazon"
        return nil unless LibraryGroup.site_config.amazon_hostname

        book_jacket = manifestation.amazon_book_jacket
        if book_jacket
          link_to image_tag(book_jacket[:url], width: book_jacket[:width], height: book_jacket[:height], alt: manifestation.original_title, class: 'book_jacket', itemprop: 'image'), "https://#{LibraryGroup.site_config.amazon_hostname}/dp/#{book_jacket[:asin]}"
        end
      when "google"
        render partial: 'manifestations/google_book_thumbnail', locals: {manifestation: manifestation}
      when "hanmotocom"
        render partial: 'manifestations/hanmotocom_thumbnail', locals: {manifestation: manifestation}
      when "openbd"
        render partial: 'manifestations/openbd_thumbnail', locals: {manifestation: manifestation}
      end
    end

    def amazon_link(asin, hostname = LibraryGroup.site_config.amazon_hostname)
      return nil if asin.blank?

      "https://#{hostname}/dp/#{asin}"
    end

    def book_jacket_source_link(source = LibraryGroup.site_config.book_jacket_source)
      case source
      when "google"
        link_to "Google Books", "https://books.google.com/"
      when "amazon"
        link_to "Amazon Web Services", "https://aws.amazon.com/"
      end
    end

    def book_jacket_header(source = LibraryGroup.site_config.book_jacket_source)
      string = ''
      case source
      when "google"
        string << javascript_tag(nil, src: "https://www.google.com/jsapi")
        string << render('manifestations/google_book_thumbnail_header')
      when "openbd"
        string << render('manifestations/openbd_thumbnail_header')
      end
      string.html_safe
    end

    def screenshot_generator_link(generator = LibraryGroup.site_config.screenshot_generator)
      case generator
      when "mozshot"
        link_to "MozShot", "https://blinky.nemui.org/"
      when "simpleapi"
        link_to "SimpleAPI", "http://img.simpleapi.net/"
      when "heartrails"
        link_to "HeartRails Capture", "http://capture.heartrails.com/"
      when "thumbalizr"
        link_to "thumbalizr", "https://www.thumbalizr.com/"
      end
    end
  end
end
