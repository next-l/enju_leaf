class FamilyUser < ActiveRecord::Base
  validates_uniqueness_of :user_id
  validates_associated :user, :family
  validates_presence_of :user_id, :family_id
  belongs_to :user, :validate => true
  belongs_to :family, :validate => true
end
