class Profile < ActiveRecord::Base
  attr_accessible :full_name, :user_number, :library_id, :keyword_list, :note,
    :user_group_id, :user_id, :locale, :required_role_id
  attr_accessible :full_name, :user_number, :library_id, :keyword_list, :note,
    :user_group_id, :user_id, :locale, :required_role_id,
    as: :admin

  belongs_to :user
  belongs_to :library, :validate => true
  belongs_to :user_group
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true

  validates_associated :user_group, :library, :user
  validates_presence_of :user_group, :library, :locale, :user #, :user_number
  validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true

  searchable do
    text :user_number, :full_name, :note
    string :user_number
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  user_group_id    :integer
#  library_id       :integer
#  locale           :string(255)
#  user_number      :string(255)
#  full_name        :text
#  note             :text
#  keyword_list     :text
#  required_role_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
