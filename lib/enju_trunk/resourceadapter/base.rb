module EnjuTrunk
  module ResourceAdapter
    class Base

      def logger
        defined?(Rails.logger) ? Rails.logger : Logger.new($stderr)
      end
      def languages
        Language.all_cache
      end

      class NoFoundAdapter < StandardError #:nodoc:
      end

      class HeaderFormatError < StandardError #:nodoc:
      end

      class << self
        def all
          @adapters
        end

        def find_by_classname(name)
          Rails.logger.info "name=#{name}"
          return nil unless @adapters
          @adapters.each do |a| 
            Rails.logger.info "a=#{a} name=#{name}"
            return a if a.to_s == name
          end
          msg  = "#{name} is not found."
          msg += "adapters=#{@adapters}"
          raise NoFoundAdapter.new(msg)
        end

        def add(adapter_name)
          @adapters ||= []
          @adapters << adapter_name
        end

        def delete(adapter_name)
          @adapters.delete(adapter_name)
        end
      end
    end
  end
end

