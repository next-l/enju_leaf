module PatronsHelper
  include PictureFilesHelper
  def patron_custom_book_jacket(patron)
    link = ''
    patron.picture_files.each_with_index do |picture_file, i|
      if i == 0
        link += link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => :download), :rel => "patron_#{patron.id}")
      else
        link += content_tag :span, :style => "display: none" do
          link_to(show_image(picture_file, :size => :thumb), picture_file_path(picture_file, :format => :download), :rel => "patron_#{patron.id}")
        end
      end
    end
    link.html_safe
  end
end
