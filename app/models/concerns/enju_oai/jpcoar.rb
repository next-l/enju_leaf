module EnjuOai
  class Jpcoar < OAI::Provider::Metadata::Format

    def initialize
      @prefix = 'jpcoar'
      @schema = 'https://github.com/JPCOAR/schema/blob/master/1.0/jpcoar_scm.xsd'
      @namespace = 'https://github.com/JPCOAR/schema/blob/master/1.0/'
      @element_namespace = 'dc'
      @fields = [ :title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights]
    end

    def header_specification
      {
        'xmlns:jpcoar' => "https://github.com/JPCOAR/schema/blob/master/1.0/",
        'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xsi:schemaLocation' =>
          %{https://github.com/JPCOAR/schema/blob/master/1.0/
            jpcoar_scm.xsd}.gsub(/\s+/, ' ')
      }
    end

  end
end
