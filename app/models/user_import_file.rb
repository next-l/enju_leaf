class UserImportFile < ActiveRecord::Base
  attr_accessible :user_import, :edit_mode
  include ImportFile
  default_scope :order => 'user_import_files.id DESC'
  scope :not_imported, where(:state => 'pending')
  scope :stucked, where('created_at < ? AND state = ?', 1.hour.ago, 'pending')

  if Setting.uploaded_file.storage == :s3
    has_attached_file :user_import, :storage => :s3, :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
      :s3_permissions => :private
  else
    has_attached_file :user_import,
      :path => ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :user_import, :content_type => [
    'text/csv',
    'text/plain',
    'text/tab-separated-values',
    'application/octet-stream',
    'application/vnd.ms-excel'
  ]
  validates_attachment_presence :user_import
  belongs_to :user, :validate => true
  has_many :user_import_results

  state_machine :initial => :pending do
    event :sm_start do
      transition [:pending, :started] => :started
    end

    event :sm_complete do
      transition :started => :completed
    end

    event :sm_fail do
      transition :started => :failed
    end

    before_transition any => :started do |user_import_file|
      user_import_file.executed_at = Time.zone.now
    end

    before_transition any => :completed do |user_import_file|
      user_import_file.error_message = nil
    end
  end

end
