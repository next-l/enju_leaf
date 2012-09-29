module OpacHelper

  def opac_book_jacket(manifestation)
    if manifestation.picture_files.exists?
      link = ''
      manifestation.picture_files.each_with_index do |picture_file, i|
        if i == 0
          link += link_to(show_image(picture_file, :size => :thumb),
            picture_file_path(picture_file, :format => picture_file.extname), :rel => "manifestation_#{manifestation.id}")
        else
          link += '<span style="display: none">' + link_to(show_image(picture_file, :size => :thumb),
            picture_file_path(picture_file, :format => picture_file.extname), :rel => "manifestation_#{manifestation.id}") + '</span>'
        end
      end
      return link.html_safe
    else
      link = book_jacket_tag(manifestation)
      unless link
        link = screenshot_tag(manifestation)
      end
    end

    unless link
      link = link_to image_tag('unknown_resource.png', :width => '100', :height => '100', :alt => '*', :itemprop => 'image'), manifestation
    end
    link
  end
end
