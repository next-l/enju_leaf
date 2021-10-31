module PictureFilesHelper
  def show_image(picture_file, options = {size: :medium})
    case options[:size]
    when :medium
      if picture_file.picture_width.to_i >= 600
        return image_tag picture_file_path(picture_file, format: :download, size: :medium), alt: "*", width: 600
      end
    when :thumb
      if picture_file.picture_width.to_i >= 100
        return image_tag picture_file_path(picture_file, format: :download, size: :thumb), alt: "*", width: 100
      end
    end
    image_tag picture_file_path(picture_file, format: :download, size: :original), alt: "*", width: picture_file.picture_width, height: picture_file.picture_height
  end
end
