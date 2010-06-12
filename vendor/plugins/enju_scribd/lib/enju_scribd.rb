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
    def post_to_scribd!
      if self.respond_to?(:post_to_scribd) and self.post_to_scribd
        send_later(:upload_to_scribd)
      end
    end
  end
end
