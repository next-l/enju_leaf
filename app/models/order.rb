class Order < ActiveRecord::Base
  belongs_to :order_list, validate: true
  belongs_to :purchase_request, validate: true

  validates_associated :order_list, :purchase_request
  validates_presence_of :order_list, :purchase_request
  validates_uniqueness_of :purchase_request_id, scope: :order_list_id

  after_save :reindex
  after_destroy :reindex

  acts_as_list scope: :order_list

  paginates_per 10

  def reindex
    purchase_request.try(:index)
  end
end

# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  order_list_id       :bigint           not null
#  purchase_request_id :bigint           not null
#  position            :integer
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
