module PatronsHelper
  include PictureFilesHelper
  def patron_custom_book_jacket(patron)
    link = ''
    patron.picture_files.each_with_index do |picture_file, i|
      if i == 0
        link += link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => picture_file.extname), :rel => "patron_#{patron.id}")
      else
        link += '<span style="display: none">' + link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => picture_file.extname), :rel => "patron_#{patron.id}") + '</span>'
      end
    end
    link.html_safe
  end
end
