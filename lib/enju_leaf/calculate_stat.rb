module CalculateStat

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      validates_presence_of :start_date, :end_date
      validate :check_date
    end
  end

  module ClassMethods
    def calculate_stat
      self.not_calculated.each do |stat|
        stat.aasm_calculate!
      end
    end
  end

  module InstanceMethods
    def check_date
      if self.start_date and self.end_date
        if self.start_date >= self.end_date
          errors.add(:start_date)
          errors.add(:end_date)
        end
      end
    end
  end
end
