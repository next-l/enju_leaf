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

  def patron_relationship_anyone(patron, id)
    patron_relationship = patron.children.find_by_child_id(id) 
    patron_relationship = patron.parents.find_by_parent_id(id) unless patron_relationship
    return patron_relationship
  end  
end
