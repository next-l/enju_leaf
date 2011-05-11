module PictureFilesHelper
  def show_image(picture_file)
    geometry = Paperclip::Geometry.from_file(picture_file.picture)
    if geometry.width.to_i >= 600
      medium_geometry = Paperclip::Geometry.from_file(picture_file.picture.path(:medium))
      image_tag picture_file_path(picture_file, :format => :download, :size => :medium), :alt => "*", :width => medium_geometry.width, :height => medium_geometry.height
    else
      image_tag picture_file_path(picture_file, :format => :download, :size => :original), :alt => "*", :width => geometry.width, :height => geometry.height
    end
  end
end
