# upgrade from enju_leaf-1.0.5.rc1 to enju_leaf-1.0.5.rc2

message_template = MessageTemplate.where(:status => 'reservation_accepted').first
if message_template
  message_template.status = 'reservation_accepted_for_patron'
  message_template.save!
end

message_template = MessageTemplate.where(:status => 'item_received').first
if message_template
  message_template.status = 'item_received_for_patron'
  message_template.save!
end

MessageTemplate.create!(
  :status => 'reservation_for_library',
  :title => 'Reservation accepted',
  :body => 'Reservation accepted',
  :locale => 'ja'
) unless MessageTemplate.where(:status => 'reservation_for_library').first

MessageTemplate.create!(
  :status => 'item_received_for_library',
  :title => 'Item received',
  :body => 'Item received',
  :locale => 'ja'
) unless MessageTemplate.where(:status => 'item_received_for_library').first

puts "Records were added successfully!"
