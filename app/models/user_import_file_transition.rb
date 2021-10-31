class UserImportFileTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_import_file, inverse_of: :user_import_file_transitions
end

# == Schema Information
#
# Table name: user_import_file_transitions
#
#  id                  :integer          not null, primary key
#  to_state            :string
#  metadata            :text             default({})
#  sort_key            :integer
#  user_import_file_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#  most_recent         :boolean          not null
#
