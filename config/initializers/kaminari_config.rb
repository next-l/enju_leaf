Kaminari.configure do |config|
  config.default_per_page = 10
  config.window = 3
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
end

# https://github.com/amatsuda/kaminari/issues/164
module Kaminari
  module Helpers
    Paginator.class_eval do
      def to_s
        super @window_options.merge(@options).merge :paginator => self
      end
    end
  end
end
