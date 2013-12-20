class Department < ActiveRecord::Base
  attr_accessible :name, :display_name, :short_name, :note, :patron_import_file

  validates_uniqueness_of :name
  validates_presence_of :name, :display_name
  validates_format_of :name, :with => /^[0-9A-Za-z]/ #, :message =>"は半角英数字で入力してください。"

  default_scope :order => 'position'
  paginates_per 10

  after_save :name_save
  has_many :users

  def self.add_department(name)
    return nil if name.blank?
    names = [name]
    names.each do |department|
      department = Department.new
      department.display_name = name
      department.save(:validate => false)
    end
    name
  end

  def name_save
    if self.name.blank?
      self.name = self.id
      self.save
    end
  end

end
