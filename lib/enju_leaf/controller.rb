module EnjuLeaf
  module ClassMethods
    def enju_leaf
      include EnjuLeaf::InstanceMethods
      include EnjuLeaf::Controller
      include Mobylette::RespondToMobileRequests
    end

    private
    def set_error_template
      rescue_from CanCan::AccessDenied, :with => :render_403
      #rescue_from ActiveRecord::RecordNotFound, :with => :render_404
      rescue_from Errno::ECONNREFUSED, :with => :render_500
      rescue_from ActionView::MissingTemplate, :with => :render_404_invalid_format
    end
  end

  module Controller
    def self.included(base)
      base.send(:before_filter, :get_library_group, :set_locale, :set_available_languages)
      base.send(:set_error_template)
    end
  end
end
