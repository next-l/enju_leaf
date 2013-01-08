module EnjuTrunk
  module ResourceAdapter
    class Base

      attr_accessor :logger

      def logger
        @logger ||= begin
           @logger = ::Logger.new(STDOUT)
           @logger.level = ($DEBUG)?(::Logger.const_get((:debug).to_s.upcase)):(::Logger.const_get((:info).to_s.upcase))
           @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
           @logger
        end
      end

      def languages
        Language.all_cache
      end

      class NoFoundAdapter < StandardError #:nodoc:
      end

      class HeaderFormatError < StandardError #:nodoc:
      end

      class << self
        def logger
          @logger ||= begin
                        @logger = ::Logger.new(STDOUT)
                        @logger.level = ($DEBUG)?(::Logger.const_get((:debug).to_s.upcase)):(::Logger.const_get((:info).to_s.upcase))
                        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
                        @logger
                      end
        end

        def logger=(value)
          @logger = value
        end
=begin
        def logger
          @logger ||= begin
                        @logger = ::Logger.new(STDOUT)
                        @logger.level = ($DEBUG)?(::Logger.const_get((:debug).to_s.upcase)):(::Logger.const_get((:info).to_s.upcase))
                        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
                        @logger
                      end
        end
=end

        def all
          @adapters
        end

        def default
          availables = Setting.resource_adapters.split(',').inject([]){|list, a| list << a.strip} rescue nil if Setting.resource_adapters
          list = @adapters.delete_if {|a| a.display_name =~ /^Template Adapter/ }
          list.delete_if {|a| !availables.include?(a.to_s)} if availables
          return list
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

        def render
          ""
        end
      end
    end
  end
end

