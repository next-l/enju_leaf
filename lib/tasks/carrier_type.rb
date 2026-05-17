def update_carrier_type
  CarrierType.find_each do |carrier_type|
    filename = nil

    case carrier_type.name
    when "volume"
      filename = "book.png"
    when "audio_disc"
      filename = "cd.png"
    when "videodisc"
      filename = "dvd.png"
    when "online_resource"
      filename = "monitor.png"
    end

    next unless filename

    unless carrier_type.attachment.attached?
      carrier_type.attachment.attach(io: File.open("#{Rails.root}/app/assets/images/icons/#{filename}"), filename: filename)
      carrier_type.save!
    end
  end
end
