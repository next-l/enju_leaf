# -*- encoding: utf-8 -*-
module EnjuOai
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_oai
      include EnjuOai::InstanceMethods
    end

    def find_by_oai_identifier(identifier)
      self.find(identifier.to_s.split(":").last.split("-").last)
    end
  end
  
  module InstanceMethods
    def oai_identifier
      "oai:#{configatron.enju.web_hostname}:#{self.class.to_s.tableize}-#{self.id}"
    end
  end
end
