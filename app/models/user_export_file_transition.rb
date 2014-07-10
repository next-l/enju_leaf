class UserExportFileTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_export_file, inverse_of: :user_export_file_transitions
  attr_accessible :to_state, :sort_key, :metadata
end

# == Schema Information
#
# Table name: user_export_file_transitions
#
#  id                  :integer          not null, primary key
#  to_state            :string(255)
#  metadata            :text             default("{}")
#  sort_key            :integer
#  user_export_file_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#
