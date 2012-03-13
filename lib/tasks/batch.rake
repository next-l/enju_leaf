namespace :enju do
  namespace :import do
    desc 'Import resources'
    task :start => :environment do
      ResourceImportFile.import
      PatronImportFile.import
      EventImportFile.import if defined?(EnjuEvent)
    end

    task :expire => :environment do
      ResourceImportFile.expire
      PatronImportFile.expire
      EventImportFile.expire if defined?(EnjuEvent)
    end

    task :destroy => :environment do
      PatronImportFile.stucked.destroy_all
      ResourceImportFile.stucked.destroy_all
      EventImportFile.stucked.destroy_all if defined?(EnjuEvent)
    end
  end

  namespace :circulation do
    desc 'Batch processing for circulation'
    task :stat => :environment do
      if defined?(EnjuCirculation)
        UserCheckoutStat.calculate_stat
        UserReserveStat.calculate_stat
        ManifestationCheckoutStat.calculate_stat
        ManifestationReserveStat.calculate_stat
      end
      BookmarkStat.calculate_stat if defined?(EnjuBookmark)
    end

    task :expire => :environment do
      if defined?(EnjuCirculation)
        Reserve.expire
        Basket.expire
      end
    end

    task :send_notification => :environment do
      if defined?(EnjuCirculation)
        Checkout.send_due_date_notification
        Checkout.send_overdue_notification
      end
    end
  end

  namespace :message do
    desc "Send messages"
    task :send => :environment do
      MessageRequest.send_messages if defined?(EnjuMessage)
    end
  end
end
