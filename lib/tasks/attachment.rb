def migrate_attachment
  option = {
    path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  }

  AgentImportFile.where.not(agent_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :agent_import,
        file,
        option
      ).path),
      filename: file.agent_import_file_name
    )
  end

  CarrierType.where.not(attachment_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :attachment,
        file,
        option
      ).path),
      filename: file.attachment_file_name
    )
  end

  EventExportFile.where.not(event_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :event_export,
        file,
        option
      ).path),
      filename: file.event_export_file_name
    )
  end

  EventImportFile.where.not(event_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :event_import,
        file,
        option
      ).path),
      filename: file.event_import_file_name
    )
  end

  InventoryFile.where.not(inventory_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :inventory,
        file,
        option
      ).path),
      filename: file.inventory_file_name
    )
  end

  LibraryGroup.where.not(header_logo_file_name: nil).find_each do |file|
    file.header_logo.attach(
      io: File.open(Paperclip::Attachment.new(
        :header_logo,
        file,
        option
      ).path),
      filename: file.header_logo_file_name
    )
  end

  Manifestation.where.not(attachment_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :attachment,
        file,
        option
      ).path),
      filename: file.attahcment_file_name
    )
  end

  PictureFile.where.not(picture_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :picture,
        file,
        option
      ).path),
      filename: file.picture_file_name
    )
    file.save
  end

  ResourceExportFile.where.not(resource_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :resource_export,
        file,
        option
      ).path),
      filename: file.resource_export_file_name
    )
  end

  ResourceImportFile.where.not(resource_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :resource_import,
        file,
        option
      ).path),
      filename: file.resource_import_file_name
    )
  end

  UserExportFile.where.not(user_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :user_export,
        file,
        option
      ).path),
    )
  end

  UserImportFile.where.not(user_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: File.open(Paperclip::Attachment.new(
        :user_import,
        file,
        option
      ).path),
      filename: file.user_import_file_name
    )
  end
end

def migrate_attachment_s3
  AgentImportFile.where.not(agent_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :agent_import,
        file,
        option
      ).expiring_url),
      filename: file.agent_import_file_name
    )
  end

  CarrierType.where.not(attachment_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :attachment,
        file,
        option
      ).expiring_url),
      filename: file.attachment_file_name
    )
  end

  EventExportFile.where.not(event_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :event_export,
        file,
        option
      ).expiring_url),
      filename: file.event_export_file_name
    )
  end

  EventImportFile.where.not(event_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :event_import,
        file,
        option
      ).expiring_url),
      filename: file.event_import_file_name
    )
  end

  InventoryFile.where.not(inventory_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :inventory,
        file,
        option
      ).expiring_url),
      filename: file.inventory_file_name
    )
  end

  LibraryGroup.where.not(header_logo_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :header_logo,
        file,
        option
      ).expiring_url),
      filename: file.header_logo_file_name
    )
  end

  Manifestation.where.not(attachment_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :attachment,
        file,
        option
      ).expiring_url),
      filename: file.attahcment_file_name
    )
  end

  PictureFile.where.not(picture_file_name: nil).find_each do |file|
    puts file.id
      puts Paperclip::Attachment.new(
        :picture,
        file,
        option
      ).expiring_url
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :picture,
        file,
        option
      ).expiring_url),
      filename: file.picture_file_name
    )
    file.save
  end

  ResourceExportFile.where.not(resource_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :resource_export,
        file,
        option
      ).expiring_url),
      filename: file.resource_export_file_name
    )
  end

  ResourceImportFile.where.not(resource_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :resource_import,
        file,
        option
      ).expiring_url),
      filename: file.resource_import_file_name
    )
  end

  UserExportFile.where.not(user_export_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :user_export,
        file,
        option
      ).expiring_url),
      filename: file.user_export_file_name
    )
  end

  UserImportFile.where.not(user_import_file_name: nil).find_each do |file|
    file.attachment.attach(
      io: URI.open(Paperclip::Attachment.new(
        :user_import,
        file,
        option
      ).expiring_url),
      filename: file.user_import_file_name
    )
  end
end
