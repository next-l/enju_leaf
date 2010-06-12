module ScribdFuModified
  module PostToScribd
    attr_accessor :post_to_scribd

    def scribdable?
      ContentTypes.include?(get_content_type) && ipaper_id.blank? && post_to_scribd
    end
  end
end

module ScribdFu::InstanceMethods
  include ScribdFuModified::PostToScribd
end
