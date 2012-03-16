module PictureFilesHelper
  def show_image(picture_file, options = {:size => :medium})
    geometry = Paperclip::Geometry.from_file(picture_file.picture)
    case options[:size]
    when :medium
      if geometry.width.to_i >= 600
        medium_geometry = Paperclip::Geometry.from_file(picture_file.picture.path(:medium))
        return image_tag picture_file_path(picture_file, :format => :download, :size => :medium), :alt => "*", :width => medium_geometry.width.to_i, :height => medium_geometry.height.to_i
      end
    when :thumb
      if geometry.width.to_i >= 100
        thumb_geometry = Paperclip::Geometry.from_file(picture_file.picture.path(:thumb))
        return image_tag picture_file_path(picture_file, :format => :download, :size => :thumb), :alt => "*", :width => thumb_geometry.width.to_i, :height => thumb_geometry.height.to_i
      end
    end
    image_tag picture_file_path(picture_file, :format => :download, :size => :original), :alt => "*", :width => geometry.width.to_i, :height => geometry.height.to_i
  rescue
    nil
  end
end
