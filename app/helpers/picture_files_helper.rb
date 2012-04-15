module PictureFilesHelper
  def show_image(picture_file, options = {:size => :medium})
    case options[:size]
    when :medium
      if picture_file.picture.width.to_i >= 600
        return image_tag picture_file_path(picture_file, :format => :download, :size => :medium), :alt => "*", :width => picture_file.picture.width(:medium), :height => picture_file.picture.height(:medium)
      end
    when :thumb
      if picture_file.picture.width.to_i >= 100
        return image_tag picture_file_path(picture_file, :format => :download, :size => :thumb), :alt => "*", :width => picture_file.picture.width(:thumb), :height => picture_file.picture.height(:thumb)
      end
    end
    image_tag picture_file_path(picture_file, :format => :download, :size => :original), :alt => "*", :width => picture_file.picture.width, :height => picture_file.picture.height
  end
end
