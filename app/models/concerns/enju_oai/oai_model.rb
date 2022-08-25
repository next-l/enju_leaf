module EnjuOai
  module OaiModel
    extend ActiveSupport::Concern
    OAI::Provider::Base.register_format(EnjuOai::Jpcoar.instance)

    def to_oai_dc
      xml = Builder::XmlMarkup.new
      xml.tag!("oai_dc:dc",
        'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>
          %{http://www.openarchives.org/OAI/2.0/oai_dc/
            http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
        xml.tag! 'dc:title', original_title
        creators.readable_by().each do |creator|
          xml.tag! 'dc:creator', creator.full_name
        end
        subjects.each do |subject|
          xml.tag! 'dc:subject', subject.term
        end
        xml.tag! 'dc:description', description
      end

      xml.target!
    end

    def to_jpcoar
      xml = Builder::XmlMarkup.new
      xml.tag!('jpcoar:jpcoar', "xsi:schemaLocation" => "https://github.com/JPCOAR/schema/blob/master/1.0/jpcoar_scm.xsd",
        "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "xmlns:rioxxterms" => "http://www.rioxx.net/schema/v2.0/rioxxterms/",
        "xmlns:datacite" => "https://schema.datacite.org/meta/kernel-4/",
        "xmlns:oaire" => "http://namespace.openaire.eu/schema/oaire/",
        "xmlns:dcndl" => "http://ndl.go.jp/dcndl/terms/",
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:jpcoar" => "https://github.com/JPCOAR/schema/blob/master/1.0/") do
        xml.tag! 'dc:title', original_title
        xml.creators do
          creators.readable_by(current_user).each do |patron|
            xml.creatorName patron.full_name
          end
        end
      end

      xml.target!
    end
  end
end
