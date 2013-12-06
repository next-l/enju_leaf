class ManifestationType < ActiveRecord::Base
  include MasterModel
  attr_accessible :display_name, :name, :note, :position
  default_scope :order => "position"
  has_many :manifestations
  has_many :statistics if defined?(Statistic)
  scope :book, where(["name = ? OR name =? OR name like ?", 'japanese_book', 'foreign_book', '%monograph'])
  scope :series, where(["name like ? OR name like ?", '%magazine', '%serial_book'])
  scope :article, where(["name like ?", '%article'])
  scope :exinfo, where(["name like ? OR name like ?", 'unknown', 'exinfo%'])

  has_paper_trail

  def is_book?
    if ['japanese_book', 'foreign_book',
        'japanese_monograph', 'foreign_monograph'].include?(self.name)
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

  def is_japanese_article?
    if ['japanese_article'].include?(self.name)
      return true
    end
    false
  end

  def is_series?
    if ['japanese_magazine', 'foreign_magazine',
      'japanese_serial_book', 'foreign_serial_book'].include?(self.name)
      return true
    end
    false
  end

  def is_exinfo?
    if ['unknown', 'exinfo1', 'exinfo2', 'exinfo3'].include?(self.name)
      return true
    end
    false
  end

  def self.categories
    ['book', 'series', 'article', 'exinfo']
  end
  
  def self.type_ids(name)
    eval("ManifestationType.#{name}.collect(&:id)")    
  end

end
