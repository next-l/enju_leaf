class Shelf < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  scope :real, where('library_id != 1')
  belongs_to :library, :validate => true
  has_many :items, :include => [:circulation_status]
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_many :statistics

  validates_associated :library
  validates_presence_of :library, :open_shelf
  validates_uniqueness_of :display_name, :scope => :library_id

  acts_as_list :scope => :library

  def self.per_page
    10
  end

  def web_shelf?
    return true if self.id == 1
    false
  end

  def self.web
    Shelf.find(1)
  end

  def first?
    # 必ずposition順に並んでいる
    return true if library.shelves.first.position == position
    false
  end

  def localized_display_name
    display_name.localize
  end

  def destroy?
    return false if Item.where(:shelf_id => self.id).first
    return true
  end

  def open?
    return true if self.open_shelf == 0
    return false
  end

  def self.get_closing_report(item)
    logger.error "closing report"
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/shelves/close_shelf"
      report.start_new_page
      report.page.item(:export_date).value(Time.now)
      report.page.item(:title).value(item.manifestation.original_title)
      report.page.item(:call_number).value(item.call_number)
      report.page.item(:library).value(item.shelf.library.display_name.localize)
      report.page.item(:shelf).value(item.shelf.display_name.localize)
      logger.error "created report: #{Time.now}"
      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end    
  end
end

# == Schema Information
#
# Table name: shelves
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  library_id   :integer         default(1), not null
#  items_count  :integer         default(0), not null
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#  deleted_at   :datetime
#

