module BackgroundJobUtils
  def self.included(mod)
    mod.extend ClassMethods
    mod.module_eval do
      include InstanceMethods
    end
  end

  module ClassMethods
    def basename
      ''
    end

    def generate_job_name
      "#{basename}#{rand(0x100000000).to_s(36)}#{Time.now.to_i.to_s(36).reverse}"
    end
  end

  module InstanceMethods
    def logger
      ActiveRecord::Base.logger
    end

    def find_administrator
      Role.find_by_name('Administrator').users.first
    end

    def message(recipient, subject, body)
      admin = find_administrator
      [recipient, admin].uniq.each do |user|
        Message.create!(
          :recipient => user,
          :sender => admin,
          :subject => subject,
          :body => body)
      end
      Sunspot.commit
    end
  end
end
