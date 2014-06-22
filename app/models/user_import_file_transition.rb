class UserImportFileTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_import_file, inverse_of: :user_import_file_transitions
  attr_accessible :to_state, :sort_key, :metadata
end
