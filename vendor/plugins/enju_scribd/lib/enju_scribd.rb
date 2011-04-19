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

    def scribdable?
      ScribdFu::ContentTypes.include?(get_content_type) && ipaper_id.blank? && post_to_scribd
    end
  end
end
