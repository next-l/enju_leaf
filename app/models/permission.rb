class Permission < ActiveRecord::Base
  attr_accessible :action, :subject_class, :subject_id, :user_id
  belongs_to :user
end
