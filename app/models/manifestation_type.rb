class ManifestationType < ActiveRecord::Base
  include MasterModel
  attr_accessible :display_name, :name, :note, :position
  default_scope :order => "position"
  has_many :manifestations

  has_paper_trail

  def is_book?
    if ['japanese_book', 'foreign_book'].include?(self.name)
      return true
    end
    false
  end

  def is_article?
    if ['japanese_article', 'foreign_article'].include?(self.name)
      return true
    end
    false
  end

  def is_series?
    if ['japanese_magazine', 'foreign_magazine',
      'japanese_serial_book', 'foreign_serial_book',
      'japanese_monograph', 'foreign_monograph'].include?(self.name)
      return true
    end
    false
  end

  def is_exinfo?
    if ['exinfo1', 'exinfo2', 'exinfo3'].include?(self.name)
      return true
    end
    false
  end
end
