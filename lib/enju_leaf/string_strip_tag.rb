# -*- encoding: utf-8 -*-
class String
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
  def strip_with_full_size_space
    s = "　\s\v"
    self.gsub(/[#{s}]/, "")
  end
end
