module MasterModel
  def self.included(base)
    #base.extend ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      acts_as_list
      validates_uniqueness_of :name, :case_sensitive => false
      validates_presence_of :name, :display_name
      before_validation :set_display_name, :on => :create
      normalize_attributes :name
    end
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
