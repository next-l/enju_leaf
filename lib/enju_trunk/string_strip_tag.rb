# -*- encoding: utf-8 -*-
class String
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
  def strip_with_full_size_space
    s = "　\s\v"
    self.gsub(/[#{s}]/, "")
  end

  def exstrip_with_full_size_space
    self.gsub(/^[　\s]*(.*?)[　\s]*$/, '\1') 
  end
end
