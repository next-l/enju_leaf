class Permission < ActiveRecord::Base
  attr_accessible :action, :subject_class, :subject_id, :role_id
  belongs_to :role
end
