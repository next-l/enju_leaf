class LibraryReport < ActiveRecord::Base
  attr_accessible :yyyymmdd, :library_id, :visiters, :copies, :consultations

  belongs_to :library
  default_scope :order => 'yyyymmdd DESC, library_id'
  attr_accessor :report_date
  validates_presence_of :yyyymmdd, :yyyymm, :library_id
  validates_numericality_of :visiters, :copies, :consultations, :allow_blank => true
  validate :date_valid
  before_validation :set_yyyymm

  searchable do
    integer :library_id
    integer :yyyymm
  end

  paginates_per 10

  def set_yyyymm
    self.yyyymm = self.yyyymmdd.to_s[0,6].to_i
  end
  
  def date_valid
    unless self.yyyymmdd.to_s =~ /^\d{8}$/
      errors.add(:yyyymmdd)
      return false
    end
    begin 
      Time.parse(self.yyyymmdd.to_s)
      return true
    rescue ArgumentError
      errors.add(:yyyymmdd)
      return false
    end
  end
end
