require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'realize')
class Realize < ActiveRecord::Base
  belongs_to :patron

  validates_associated :patron
  after_save :reindex
  after_destroy :reindex

  paginates_per 10

  has_paper_trail

  def reindex
    patron.try(:index)
    expression.try(:index)
  end
end

# == Schema Information
#
# Table name: realizes
#
#  id            :integer         not null, primary key
#  patron_id     :integer         not null
#  expression_id :integer         not null
#  position      :integer
#  type          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

