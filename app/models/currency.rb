class Currency < ActiveRecord::Base
  attr_accessible :created_at, :display_name, :id, :name, :updated_at
  has_many :exchange_rates
 
  paginates_per 10

  validates :name, :presence => true
  validates :display_name, :presence => true

  validates_format_of :name, :with => /^[0-9A-Za-z]+$/, :message => I18n.t('currency.invalid_name')

  def destroy?
    return false if ExchangeRate.where(:currency_id => self.id).first
    return true
  end


end
