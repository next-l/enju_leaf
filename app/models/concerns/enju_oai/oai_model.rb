module EnjuOai
  module OaiModel
    extend ActiveSupport::Concern

    module ClassMethods
      def find_by_oai_identifier(identifier)
        self.find(identifier.to_s.split(":").last.split("-").last)
      end
    end
  
    def oai_identifier
      "oai:#{::Addressable::URI.parse(LibraryGroup.site_config.url).host}:#{self.class.to_s.tableize}-#{self.id}"
    end
  end
end
