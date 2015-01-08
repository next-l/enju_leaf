module Sunspot
  module Query
    class StartRecord #:nodoc:
      attr_reader :start_record, :maximum_record

      def initialize(start_record = nil, maximum_record = nil)
        self.start_record, self.maximum_record = start_record, maximum_record
      end

      def to_params
        { :start => start, :rows => rows }
      end

      def start_record=(start_record)
        @start_record = start_record.to_i - 1 if start_record
      end

      def maximum_record=(maximum_record)
        @maximum_record = maximum_record.to_i if maximum_record
      end

      private

      def start
        @start_record
      end

      def rows
        @maximum_record
      end
    end

    class CommonQuery
      def start_record(start, maximum)
        if @start_record
          @start_record.start = start
          @start_record.maximum = maximum
        else
          @components << @start_record = StartRecord.new(start, maximum)
        end
      end
    end
  end

  module DSL #:nodoc:
    class Query < FieldQuery
      def start_record(options = {})
        start = options.delete(:start)
        maximum = options.delete(:maximum)
        raise ArgumentError, "unknown argument #{options.keys.first.inspect} passed to paginate" unless options.empty?
        @query.start_record(start, maximum)
      end
    end
  end
end
