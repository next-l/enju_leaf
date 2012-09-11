class PatronMerge < ActiveRecord::Base
  belongs_to :patron, :validate => true
  belongs_to :patron_merge_list, :validate => true
  validates_presence_of :patron, :patron_merge_list
  validates_associated :patron, :patron_merge_list

  paginates_per 10
end

# == Schema Information
#
# Table name: patron_merges
#
#  id                   :integer         not null, primary key
#  patron_id            :integer         not null
#  patron_merge_list_id :integer         not null
#  created_at           :datetime
#  updated_at           :datetime
#

