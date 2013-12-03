class SeriesStatementRelationship < ActiveRecord::Base
  SOURCES = { 0 => 'enju', 1 => 'NACSIS' } 
 
  default_scope :order => 'seq asc'
  attr_accessible :relationship_family_id, :fid, :seq, :series_statement_relationship_type_id, :source,
                  :bbid, :abid, :before_series_statement_relationship_id, :after_series_statement_relationship_id
  belongs_to :before_series_statement_relationship, :class_name => 'SeriesStatement'
  belongs_to :after_series_statement_relationship,  :class_name => 'SeriesStatement'
  belongs_to :series_statement_relationship_type
  belongs_to :relationship_family

  validates_presence_of :relationship_family_id, :seq, :series_statement_relationship_type_id, :source
  validates_length_of :before_series_statement_relationship_id, 
    :is => 0, 
    :if => proc { |p| p.series_statement_relationship_type_id.to_i == 1 },
    :message => I18n.t('series_statement_relationship.not_necessary')
  validates_length_of :after_series_statement_relationship_id, 
    :is => 0, 
    :if => proc { |p| p.series_statement_relationship_type_id.to_i == 5 },
    :message => I18n.t('series_statement_relationship.not_necessary')
  validates_length_of :bbid, 
    :is => 0, 
    :if => proc { |p| p.series_statement_relationship_type_id.to_i == 1 and p.source == 1 },
    :message => I18n.t('series_statement_relationship.not_necessary')
  validates_length_of :abid, 
    :is => 0, 
    :if => proc { |p| p.series_statement_relationship_type_id.to_i == 5 and p.source == 1 },
    :message => I18n.t('series_statement_relationship.not_necessary')
  validate :exist_series_statement?

  after_save :reindex
  after_destroy :reindex

  def reindex
    before_series_statement_relationship.try(:index)
    after_series_statement_relationship.try(:index)
    Sunspot.commit
  end

  def exist_series_statement?
    if self.before_series_statement_relationship_id.present?
      before_series_statement = SeriesStatement.find(self.before_series_statement_relationship_id) rescue nil
      unless before_series_statement
        errors.add(:before_series_statement_relationship_id, I18n.t('series_statement_relationship.not_exist_series_statement'))
      end
    end
    if self.after_series_statement_relationship_id.present?
      after_series_statement = SeriesStatement.find(self.after_series_statement_relationship_id) rescue nil
      unless after_series_statement
        errors.add(:after_series_statement_relationship_id, I18n.t('series_statement_relationship.not_exist_series_statement'))
      end
    end
  end
end
