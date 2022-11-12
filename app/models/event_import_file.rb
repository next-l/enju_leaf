class EventImportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: EventImportFileTransition,
    initial_state: EventImportFileStateMachine.initial_state
  ]
  include ImportFile
  scope :not_imported, -> {in_state(:pending)}
  scope :stucked, -> {in_state(:pending).where('event_import_files.created_at < ?', 1.hour.ago)}

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :event_import, storage: :s3,
      s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME'],
        s3_host_name: ENV['S3_HOST_NAME']
      },
      s3_permissions: :private
  else
    has_attached_file :event_import,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :event_import, content_type: [
    'text/csv',
    'text/plain',
    'text/tab-separated-values',
    'application/octet-stream',
    'application/vnd.ms-excel'
  ]
  validates_attachment_presence :event_import
  belongs_to :user
  belongs_to :default_library, class_name: 'Library', optional: true
  belongs_to :default_event_category, class_name: 'EventCategory', optional: true
  has_many :event_import_results, dependent: :destroy

  has_many :event_import_file_transitions, autosave: false, dependent: :destroy

  attr_accessor :mode

  def state_machine
    EventImportFileStateMachine.new(self, transition_class: EventImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def import
    transition_to!(:started)
    num = { imported: 0, failed: 0 }
    rows = open_import_file(create_import_temp_file(event_import))
    check_field(rows.first)
    row_num = 1

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?

      event_import_result = EventImportResult.new(event_import_file_id: id, body: row.fields.join("\t"))

      event = Event.new
      event.name = row['name'].to_s.strip
      event.display_name = row['display_name']
      event.note = row['note']
      event.start_at = Time.zone.parse(row['start_at']) if row['start_at'].present?
      event.end_at = Time.zone.parse(row['end_at']) if row['end_at'].present?
      category = row['event_category'].to_s.strip
      if %w(t true TRUE).include?(row['all_day'].to_s.strip)
        event.all_day = true
      else
        event.all_day = false
      end
      library = Library.find_by(name: row['library'])
      library = default_library || Library.web if library.blank?
      event.library = library
      event_category = EventCategory.find_by(name: row['event_category'])
      event_category = default_event_category if event_category.blank?
      event.event_category = event_category

      if event.save
        event_import_result.event = event
        num[:imported] += 1
      else
        num[:failed] += 1
      end
      event_import_result.save!
    end
    Sunspot.commit
    rows.close
    transition_to!(:completed)
    mailer = EventImportMailer.completed(self)
    send_message(mailer)
    num
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = EventImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def modify
    transition_to!(:started)
    rows = open_import_file(create_import_temp_file(event_import))
    check_field(rows.first)
    row_num = 1

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?

      event = Event.find(row['id'].to_s.strip)
      event_category = EventCategory.find_by(name: row['event_category'].to_s.strip)
      event.event_category = event_category if event_category
      library = Library.find_by(name: row['library'].to_s.strip)
      event.library = library if library
      event.name = row['name'] if row['name'].to_s.strip.present?
      event.start_at = Time.zone.parse(row['start_at']) if row['start_at'].present?
      event.end_at = Time.zone.parse(row['end_at']) if row['end_at'].present?
      event.note = row['note'] if row['note'].to_s.strip.present?
      if %w(t true TRUE).include?(row['all_day'].to_s.strip)
        event.all_day = true
      else
        event.all_day = false
      end
      event.save!
    end
    transition_to!(:completed)
    mailer = EventImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = EventImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def remove
    transition_to!(:started)
    rows = open_import_file(create_import_temp_file(event_import))
    rows.shift
    row_num = 1

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?

      event = Event.find(row['id'].to_s.strip)
      event.picture_files.destroy_all # workaround
      event.reload
      event.destroy
    end
    transition_to!(:completed)
    mailer = EventImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    save
    transition_to!(:failed)
    mailer = EventImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def self.import
    EventImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue StandardError
    Rails.logger.info "#{Time.zone.now} importing events failed!"
  end

  private

  def open_import_file(tempfile)
    file = CSV.open(tempfile, col_sep: "\t")
    header_columns = EventImportResult.header
    header = file.first
    ignored_columns = header - header_columns
    unless ignored_columns.empty?
      self.error_message = I18n.t('import.following_column_were_ignored', column: ignored_columns.join(', '))
      save!
    end
    rows = CSV.open(tempfile, headers: header, col_sep: "\t")
    event_import_result = EventImportResult.new
    event_import_result.assign_attributes({ event_import_file_id: id, body: header.join("\t") })
    event_import_result.save!
    tempfile.close(true)
    file.close
    rows
  end

  def check_field(field)
    if [field['name']].reject{|f| f.to_s.strip == ""}.empty?
      raise "You should specify a name in the first line"
    end
    if [field['start_at'], field['end_at']].reject{|f| f.to_s.strip == ""}.empty?
      raise "You should specify dates in the first line"
    end
  end
end

# == Schema Information
#
# Table name: event_import_files
#
#  id                        :bigint           not null, primary key
#  parent_id                 :integer
#  content_type              :string
#  size                      :integer
#  user_id                   :bigint
#  note                      :text
#  executed_at               :datetime
#  event_import_file_name    :string
#  event_import_content_type :string
#  event_import_file_size    :integer
#  event_import_updated_at   :datetime
#  edit_mode                 :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  event_import_fingerprint  :string
#  error_message             :text
#  user_encoding             :string
#  default_library_id        :integer
#  default_event_category_id :integer
#
