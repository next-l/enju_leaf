class Object
  def returning(object, &block)
    tap do
      yield block
      return object
    end
  end
end

module Sunspot #:nodoc:
  module Rails #:nodoc:
    module Adapters
      class ActiveRecordDataAccessor < Sunspot::Adapters::DataAccessor
        
        private
        
        def options_for_find
          {}.tap do |options|
            options[:include] = @include unless @include.blank?
            options[:select]  =  @select unless  @select.blank?
          end
        end
      end
    end
  end
end
