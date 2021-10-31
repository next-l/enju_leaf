module EnjuCirculation
  module EnjuProfile
    extend ActiveSupport::Concern

    def reset_checkout_icalendar_token
      self.checkout_icalendar_token = SecureRandom.hex(16)
    end

    def delete_checkout_icalendar_token
      self.checkout_icalendar_token = nil
    end
  end
end
