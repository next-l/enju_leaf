module EnjuOai
  module OaiModel
    extend ActiveSupport::Concern

    def oai_identifier
      "oai:#{::Addressable::URI.parse(LibraryGroup.site_config.url).host}:#{self.class.to_s.tableize}-#{self.id}"
    end

    def to_jpcoar
      xml = Builder::XmlMarkup.new
      xml_builder.jpcoar "xsi:schemaLocation" => "https://github.com/JPCOAR/schema/blob/master/1.0/jpcoar_scm.xsd",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:rioxxterms" => "http://www.rioxx.net/schema/v2.0/rioxxterms/",
        "xmlns:datacite" => "https://schema.datacite.org/meta/kernel-4/",
        "xmlns:oaire" => "http://namespace.openaire.eu/schema/oaire/",
        "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns" => "https://github.com/JPCOAR/schema/blob/master/1.0/" do
        xml_builder.tag! 'dc:title', original_title

        xml_builder.creators do
          creators.readable_by(current_user).each do |patron|
            xml_builder.creatorName patron.full_name
          end
        end
      end

      xml.target!
    end
  end
end
