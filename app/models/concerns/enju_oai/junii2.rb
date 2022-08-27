module EnjuOai
  class Junii2 < OAI::Provider::Metadata::Format

    def initialize
      @prefix = 'junii2'
      @schema = 'http://irdb.nii.ac.jp/oai http://irdb.nii.ac.jp/oai/junii2-3-1.xsd'
      @namespace = 'http://irdb.nii.ac.jp/oai'
      @element_namespace = 'dc'
      @fields = [ :title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights]
    end

    def header_specification
      {
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'http://irdb.nii.ac.jp/oai http://irdb.nii.ac.jp/oai/junii2-3-1.xsd'
      }
    end
  end
end
