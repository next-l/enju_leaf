class Profile < ActiveRecord::Base
  belongs_to :user
  belongs_to :library, :validate => true
  belongs_to :user_group
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id' #, :validate => true

  validates_associated :user_group, :library #, :agent
  validates_presence_of :user_group, :library, :locale #, :user_number
  validates :user_number, :uniqueness => true, :format => {:with => /\A[0-9A-Za-z_]+\Z/}, :allow_blank => true

  searchable do
    text :user_number, :full_name, :note
    string :user_number
  end
end
