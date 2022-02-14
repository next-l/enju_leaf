class EventExportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EventExportFileTransition,
    initial_state: EventExportFileStateMachine.initial_state
  ]
  include ExportFile

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :event_export, storage: :s3,
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME']
      },
      s3_permissions: :private
  else
    has_attached_file :event_export,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :event_export, content_type: /\Atext\/plain\Z/
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
      self.event_export = StringIO.new(tsv)
      self.event_export.instance_write(:filename, "event_export.txt")
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
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  event_export_file_name    :string
#  event_export_content_type :string
#  event_export_file_size    :bigint
#  event_export_updated_at   :datetime
#  executed_at               :datetime
#  created_at                :datetime
#  updated_at                :datetime
#
