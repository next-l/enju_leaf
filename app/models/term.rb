class Term < ActiveRecord::Base
  validates_presence_of :display_name, :start_at, :end_at
  before_save :set_end_date
  belongs_to :budget

  def validate
    unless self.start_at < self.end_at
      errors.add(:base, I18n.t('activerecord.attributes.term.end_at_invalid'))
    end
  end
 
  def set_end_date
    self.end_at = self.end_at.end_of_day
  end

  def destroy?
    return false if Budget.where(:term_id => self.id).first
    return true
  end
end

