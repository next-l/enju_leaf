class UserImportResult < ActiveRecord::Base
  #attr_accessible :user_import_file_id, :user_id, :body
  default_scope {order('user_import_results.id')}
  scope :file_id, proc{|file_id| where(:user_import_file_id => file_id)}
  scope :failed, -> {where(:user_id => nil)}

  belongs_to :user_import_file
  belongs_to :user
end
