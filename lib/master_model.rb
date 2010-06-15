module MasterModel
  def self.included(base)
  #  base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def set_display_name
      self.display_name = self.name if self.display_name.blank?
    end
  
    def check_creatable
      if creatable?
        raise NotModifiableError
      end
    end

    def check_deletable
      if deletable?
        raise NotModifiableError
      end
    end

    def creatable?
      false
    end

    def deletable?
      false
    end
  end

  class NotModifiableError < StandardError; end
end
