module Sunspot
  module Search #:nodoc:
    class AbstractSearch
      def execute
        reset
        params = @query.to_params
        @solr_result = @connection.post "#{request_handler}", :data => params, :headers => {'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8'}
        self
      end
    end
  end
end
