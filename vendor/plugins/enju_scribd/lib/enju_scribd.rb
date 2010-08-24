module EnjuScribd
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_scribd
      include EnjuScribd::InstanceMethods
    end
  end

  module InstanceMethods
    attr_accessor :post_to_scribd

    def post_to_scribd!
      if self.respond_to?(:post_to_scribd) and self.post_to_scribd
        self.delay.upload_to_scribd
      end
    end
  end
end
