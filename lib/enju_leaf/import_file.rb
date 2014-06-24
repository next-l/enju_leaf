module ImportFile
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def expire
      self.stucked.find_each do |file|
        file.destroy
      end
    end
  end
end
