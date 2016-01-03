class UserExportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries
  include ExportFile

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :user_export, storage: :s3,
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME']
      },
      s3_permissions: :private
  else
    has_attached_file :user_export,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :user_export, content_type: /\Atext\/plain\Z/

  has_many :user_export_file_transitions

  def state_machine
    UserExportFileStateMachine.new(self, transition_class: UserExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  # エクスポートの処理を実行します。
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
#  id                   :integer          not null, primary key
#  user_id              :integer
#  executed_at          :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  user_export_id       :string
#  user_export_size     :integer
#  user_import_filename :string
#
