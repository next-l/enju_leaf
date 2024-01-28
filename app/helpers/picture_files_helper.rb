module PictureFilesHelper
  def show_image(picture_file, options = {size: :medium})
    return unless picture_file.attachment.attached?

    case options[:size]
    when :medium
      image_tag picture_file.attachment.variant(resize_to_limit: [600, nil]), alt: "*", width: 600
    when :thumb
      image_tag picture_file.attachment.variant(resize_to_limit: [100, nil]), alt: "*", width: 100
    else
      image_tag picture_file.attachment, alt: "*", width: picture_file.attachment.metadata['width'], height: picture_file.attachment.metadata['height']
    end
  end
end
