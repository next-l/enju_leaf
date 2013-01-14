module Sunspot
  module Query
    class Spellcheck < Connective::Conjunction
      attr_accessor :options

      def initialize(options = {})
        options.assert_valid_keys(:collate)
        @options = options
      end

      def to_params
        @options.inject({ :spellcheck => 'true' }) do |params, (key, val)|
          params.tap {|h| h[:"spellcheck.#{key}"] = val.to_s }
        end
      end
    end

    class CommonQuery
      def add_spellcheck(options = {})
        @components << Spellcheck.new(options)
      end
    end
  end

  module Search
    class AbstractSearch
      def raw_suggestions
        ["spellcheck", "suggestions"].inject(@solr_result){|h,k| h && h[k] }
      end

      def suggestions
        suggestions = raw_suggestions
        return nil unless suggestions.is_a?(Array)

        suggestions.each_slice(2).inject({}) do |hash, (key, val)|
          next unless key.is_a?(String)

          if val.is_a?(String)
            hash[key.to_sym] = val
          else
            hash[key] = val.try(:[], "suggestion")
          end

          hash
        end
      end

      def collation
        suggestions.try(:[], :collation)
      end
    end
  end

  module DSL
    class StandardQuery
      def spellcheck(options = {})
        @query.add_spellcheck(options)
      end
    end
  end
end
