module CalculateStat

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def calculate_stat
      self.not_calculated.each do |stat|
        stat.aasm_calculate!
      end
    end
  end
end
