class UserExportFile < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordModel
  belongs_to :user
  has_attached_file :user_export
  validates_attachment_content_type :user_export, :content_type => /\Atext\/plain\Z/
  validates :user, presence: true
  attr_accessible :mode
  attr_accessor :mode

  has_many :user_export_file_transitions

  def state_machine
    UserExportFileStateMachine.new(self, transition_class: UserExportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def export!
    transition_to!(:started)
    tempfile = Tempfile.new(['user_export_file_', '.txt'])
    file = User.export(format: :tsv)
    tempfile.puts(file)
    tempfile.close
    self.user_export = File.new(tempfile.path, "r")
    if save
      message = Message.create(
        sender: User.find(1),
        recipient: user.username,
        subject: 'export completed',
        body: I18n.t('export.export_completed')
      )
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
end

# == Schema Information
#
# Table name: user_export_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  user_export_file_name    :string(255)
#  user_export_content_type :string(255)
#  user_export_file_size    :integer
#  user_export_updated_at   :datetime
#  executed_at              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
