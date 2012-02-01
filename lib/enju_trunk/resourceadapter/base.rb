module EnjuTrunk
  module ResourceAdapter
    class Base
      class << self
        def all
          @adapters
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

