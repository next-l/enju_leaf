module EnjuOai
  class Dcndl < OAI::Provider::Metadata::Format

    def initialize
      @prefix = 'dcndl'
      @schema = nil
      @namespace = 'http://ndl.go.jp/dcndl/terms/'
      @element_namespace = 'dc'
      @fields = [ :title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights]
    end
  end
end
