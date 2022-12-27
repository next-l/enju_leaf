def update_carrier_type
  CarrierType.find_each do |carrier_type|
    case carrier_type.name
    when "volume"
      carrier_type = CarrierType.find_by(name: 'volume')
      if carrier_type
        unless carrier_type.attachment.attached?
          carrier_type.attachment.attach(io: File.open("#{File.dirname(__FILE__)}/../../app/assets/images/icons/book.png"), filename: 'book.png')
          carrier_type.save!
        end
      end
    when "audio_disc"
      carrier_type = CarrierType.find_by(name: 'audio_disc')
      if carrier_type
        unless carrier_type.attachment.attached?
          carrier_type.attachment.attach(io: File.open("#{File.dirname(__FILE__)}/../../app/assets/images/icons/cd.png"), filename: 'cd.png')
          carrier_type.save!
        end
      end
    when "videodisc"
      carrier_type = CarrierType.find_by(name: 'videodisc')
      if carrier_type
        unless carrier_type.attachment.attached?
          carrier_type.attachment.attach(io: File.open("#{File.dirname(__FILE__)}/../../app/assets/images/icons/dvd.png"), filename: 'dvd.png')
          carrier_type.save!
        end
      end
    when "online_resource"
      carrier_type = CarrierType.find_by(name: 'online_resource')
      if carrier_type
        unless carrier_type.attachment.attached?
          carrier_type.attachment.attach(io: File.open("#{File.dirname(__FILE__)}/../../app/assets/images/icons/monitor.png"), filename: 'monitor.png')
          carrier_type.save!
        end
      end
    end
  end
end
