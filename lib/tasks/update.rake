namespace :enju do
  # https://gist.github.com/551136
  def exception_notify
    yield
  rescue Exception => exception
    env = {}
    env['exception_notifier.options'] = {
      :email_prefix => '[Exception] ',
      :sender_address => '"Exception notifier" <notifier@example.com>',
      :exception_recipients => 'notify@example.com',
      :sections => ['backtrace']
    }
    ExceptionNotifier::Notifier.exception_notification(env, exception).deliver
    raise exception
  end

  namespace :update do
    desc '1.0.5.rc2'
    task :to_1_0_5_rc2 => :environment do
      exception_notify{
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
          :status => 'reservation_accepted_for_library',
          :title => 'Reservation accepted',
          :body => 'Reservation accepted',
          :locale => 'ja'
        ) unless MessageTemplate.where(:status => 'reservation_accepted_for_library').first

        MessageTemplate.create!(
          :status => 'item_received_for_library',
          :title => 'Item received',
          :body => 'Item received',
          :locale => 'ja'
        ) unless MessageTemplate.where(:status => 'item_received_for_library').first

        puts "Records were added successfully!"
      }
    end
  end
end
