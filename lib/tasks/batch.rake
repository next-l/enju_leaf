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

  namespace :import do
    desc 'Import resources'
    task :start => :environment do
      exception_notify{
        ResourceImportFile.import
        PatronImportFile.import
        EventImportFile.import if defined?(EnjuEvent)
      }
    end

    task :expire => :environment do
      exception_notify{
        ResourceImportFile.expire
        PatronImportFile.expire
        EventImportFile.expire if defined?(EnjuEvent)
      }
    end

    task :destroy => :environment do
      exception_notify{
        PatronImportFile.stucked.destroy_all
        ResourceImportFile.stucked.destroy_all
        EventImportFile.stucked.destroy_all if defined?(EnjuEvent)
      }
    end
  end

  namespace :circulation do
    desc 'Batch processing for circulation'
    task :stat => :environment do
      exception_notify{
        if defined?(EnjuCirculation)
          UserCheckoutStat.calculate_stat
          UserReserveStat.calculate_stat
          ManifestationCheckoutStat.calculate_stat
          ManifestationReserveStat.calculate_stat
        end
      }
    end

    task :expire => :environment do
      exception_notify{
        if defined?(EnjuCirculation)
          Reserve.expire
          Basket.expire
        end
      }
    end

    task :send_notification => :environment do
      exception_notify{
        if defined?(EnjuCirculation)
          Checkout.send_due_date_notification
          Checkout.send_overdue_notification
        end
      }
    end
  end

  namespace :message do
    desc "Send messages"
    task :send => :environment do
      exception_notify{
        MessageRequest.send_messages if defined?(EnjuMessage)
      }
    end
  end

  namespace :bookmark do
    desc 'Batch processing for bookmark'
    task :stat => :environment do
      exception_notify{
        BookmarkStat.calculate_stat if defined?(EnjuBookmark)
      }
    end
  end

  namespace :export do
    desc "export items"
    task :item => :environment do
      Item.find_each do |item|
        puts "#{item.id}\t#{item.manifestation.id}\t#{item.call_number}\t#{item.item_identifier}\t#{item.manifestation.ndc}\t#{item.shelf.name}"
      end
    end
  end
end
