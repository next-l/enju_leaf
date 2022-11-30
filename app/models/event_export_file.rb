class EventExportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EventExportFileTransition,
    initial_state: EventExportFileStateMachine.initial_state
  ]
  include ExportFile

  has_one_attached :attachment
  has_many :event_export_file_transitions, autosave: false

  def state_machine
    EventExportFileStateMachine.new(self, transition_class: EventExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def export!
    role_name = user.try(:role).try(:name)
    tsv = Event.export(role: role_name)

    EventExportFile.transaction do
      transition_to!(:started)
      role_name = user.try(:role).try(:name)
      attachment.attach(io: StringIO.new(tsv), filename: 'event_export.txt')
      save!
      transition_to!(:completed)
    end
    mailer = EventExportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    transition_to!(:failed)
    mailer = EventExportMailer.failed(self)
    send_message(mailer)
    raise e
  end
end

# == Schema Information
#
# Table name: event_export_files
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  executed_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
