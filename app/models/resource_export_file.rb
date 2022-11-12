class ResourceExportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ResourceExportFileTransition,
    initial_state: ResourceExportFileStateMachine.initial_state
  ]
  include ExportFile

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :resource_export, storage: :s3,
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME'],
        s3_region: ENV['S3_REGION']
      },
      s3_permissions: :private
  else
    has_attached_file :resource_export,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :resource_export, content_type: /\Atext\/plain\Z/

  has_many :resource_export_file_transitions, autosave: false, dependent: :destroy

  def state_machine
    ResourceExportFileStateMachine.new(self, transition_class: ResourceExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def export!
    transition_to!(:started)
    role_name = user.try(:role).try(:name)
    tsv = Manifestation.export(role: role_name)
    file = StringIO.new(tsv)
    file.class.class_eval { attr_accessor :original_filename, :content_type }
    file.original_filename = 'resource_export.txt'
    self.resource_export = file
    save!
    transition_to!(:completed)
    mailer = ResourceExportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    transition_to!(:failed)
    mailer = ResourceExportMailer.failed(self)
    send_message(mailer)
    raise e
  end
end

# == Schema Information
#
# Table name: resource_export_files
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  resource_export_file_name    :string
#  resource_export_content_type :string
#  resource_export_file_size    :bigint
#  resource_export_updated_at   :datetime
#  executed_at                  :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
