module PatronsHelper
  include PictureFilesHelper
  def patron_custom_book_jacket(patron)
    picture_file = patron.picture_files.first
    if picture_file
      link_to show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => picture_file.extname), :rel => "patron_#{patron.id}"
    end
  end
end
