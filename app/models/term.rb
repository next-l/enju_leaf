class Term < ActiveRecord::Base
  validates_presence_of :display_name, :start_at, :end_at
  before_save :set_end_date
  has_many :budgets

  scope :current, where(["start_at <= :now and :now < end_at", {:now => Time.now}])

  def self.current_term
    self.current.first
  end

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

  def self.previous_term
    t = Term.where("start_at <= ? AND end_at >= ?", Time.now, Time.now).first
    return nil unless t
    s = t.start_at - 1.day
    Term.where("start_at <= ? AND end_at >= ?", s, s).first
  end
  def self.current_term
    Term.where("start_at <= ? AND end_at >= ?", Time.now, Time.now).first
  end
  def self.get_term_end_at(time)
    term = Term.where("start_at <= ? AND end_at >= ?", time, time).first
    return term['end_at']
  end

end

