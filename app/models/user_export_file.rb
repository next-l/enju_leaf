class UserExportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: UserExportFileTransition,
    initial_state: UserExportFileStateMachine.initial_state
  ]
  include ExportFile

  has_one_attached :attachment

  has_many :user_export_file_transitions, autosave: false, dependent: :destroy

  def state_machine
    UserExportFileStateMachine.new(self, transition_class: UserExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  # エクスポートの処理を実行します。
  def export!
    transition_to!(:started)
    tempfile = Tempfile.new(['user_export_file_', '.txt'])
    file = User.export(format: :text)
    tempfile.puts(file)
    tempfile.close
    attachment.attach(io: File.new(tempfile.path, 'r'), filename: 'user_export.txt')
    save!
    transition_to!(:completed)
    mailer = UserExportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    transition_to!(:failed)
    mailer = UserExportMailer.failed(self)
    send_message(mailer)
  rescue StandardError => e
    raise e
  end
end

# == Schema Information
#
# Table name: user_export_files
#
#  id                       :bigint           not null, primary key
#  user_id                  :bigint
#  user_export_file_name    :string
#  user_export_content_type :string
#  user_export_file_size    :bigint
#  user_export_updated_at   :datetime
#  executed_at              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
