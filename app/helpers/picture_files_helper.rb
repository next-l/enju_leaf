module PictureFilesHelper
  def show_image(picture_file, options = {size: :medium})
    return unless picture_file.attachment.attached?

    case options[:size]
    when :medium
      if picture_file.attachment.metadata['width'].to_i >= 600
        return image_tag picture_file.attachment.representation(resize_to_limit: [600, nil]), alt: "*", width: 600
      end
    when :thumb
      if picture_file.attachment.metadata['width'].to_i >= 100
        return image_tag picture_file.attachment.representation(resize_to_limit: [100, nil]), alt: "*", width: 100
      end
    end

    image_tag picture_file.attachment, alt: "*", width: picture_file.attachment.metadata['width'], height: picture_file.attachment.metadata['height']
  end
end
