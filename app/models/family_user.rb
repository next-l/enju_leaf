class FamilyUser < ActiveRecord::Base
  validates_uniqueness_of :user_id
  belongs_to :user, :validate => true
  belongs_to :family, :validate => true
end
