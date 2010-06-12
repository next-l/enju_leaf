class UserGroupHasCheckoutType < ActiveRecord::Base
  scope :available_for_item, lambda {|item| {:conditions => {:checkout_type_id => item.checkout_type.id}}}
  scope :available_for_carrier_type, lambda {|carrier_type| {:include => {:checkout_type => :carrier_types}, :conditions => ['carrier_types.id = ?', carrier_type.id]}}

  belongs_to :user_group, :validate => true
  belongs_to :checkout_type, :validate => true

  validates_presence_of :user_group, :checkout_type
  validates_associated :user_group, :checkout_type
  validates_uniqueness_of :checkout_type_id, :scope => :user_group_id
  after_create :create_lending_policy
  after_update :update_lending_policy

  acts_as_list :scope => :user_group_id

  def create_lending_policy
    self.checkout_type.items.find_each do |item|
      sql = ['INSERT INTO lending_policies (item_id, user_group_id, loan_period, renewal, created_at) VALUES (?, ?, ?, ?, ?)', item.id, self.user_group_id, self.checkout_period, self.checkout_renewal_limit, Time.zone.now]
      ActiveRecord::Base.connection.execute(
        self.class.send(:sanitize_sql_array, sql)
      )
    end
  end

  def update_lending_policy
    self.checkout_type.items.each do |item|
      sql = ['UPDATE lending_policies SET loan_period = ?, renewal = ?, updated_at = ? WHERE user_group_id = ? AND item_id = ?', self.user_group_id, self.checkout_period, Time.zone.now, self.checkout_renewal_limit, item.id]
      ActiveRecord::Base.connection.execute(
        self.class.send(:sanitize_sql_array, sql)
      )
    end
  end

end
