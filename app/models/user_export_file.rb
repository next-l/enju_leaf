class UserExportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  include ExportFile
  enju_export_file_model

  attachment :user_export
  has_many :user_export_file_transitions

  def state_machine
    UserExportFileStateMachine.new(self, transition_class: UserExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def export!
    transition_to!(:started)
    tempfile = Tempfile.new(['user_export_file_', '.txt'])
    file = User.export(format: :txt)
    tempfile.puts(file)
    tempfile.close
    self.user_export = File.new(tempfile.path, 'r')
    if save
      send_message
    end
    transition_to!(:completed)
  rescue => e
    transition_to!(:failed)
    raise e
  end

  private
  def self.transition_class
    UserExportFileTransition
  end

  def self.initial_state
    :pending
  end
end

# == Schema Information
#
# Table name: user_export_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  executed_at              :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  user_export_id           :string
#  user_export_file_name    :string
#  user_export_size         :integer
#  user_export_content_type :string
#
