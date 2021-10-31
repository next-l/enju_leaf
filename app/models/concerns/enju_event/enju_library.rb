module EnjuEvent
  module EnjuLibrary
    extend ActiveSupport::Concern

    included do
      has_many :events
    end

    def closed?(date)
      events.closing_days.map{ |c|
        c.start_at.beginning_of_day
      }.include?(date.beginning_of_day)
    end
  end
end
