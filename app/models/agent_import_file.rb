class AgentImportFile < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: AgentImportFileTransition,
    initial_state: AgentImportFileStateMachine.initial_state
  ]
  include ImportFile
  default_scope { order('agent_import_files.id DESC') }
  scope :not_imported, -> { in_state(:pending) }
  scope :stucked, -> { in_state(:pending).where('agent_import_files.created_at < ?', 1.hour.ago) }

  has_one_attached :attachment
  belongs_to :user
  has_many :agent_import_results, dependent: :destroy

  has_many :agent_import_file_transitions, autosave: false, dependent: :destroy

  attr_accessor :mode

  def state_machine
    AgentImportFileStateMachine.new(self, transition_class: AgentImportFileTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def import_start
    case edit_mode
    when 'create'
      import
    when 'update'
      modify
    when 'destroy'
      remove
    else
      import
    end
  end

  def import
    transition_to!(:started)
    num = { agent_imported: 0, user_imported: 0, failed: 0 }
    rows = open_import_file
    field = rows.first
    row_num = 1
    if [field['first_name'], field['last_name'], field['full_name']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify first_name, last_name or full_name in the first line"
    end

    #rows.shift

    AgentImportResult.create!(agent_import_file_id: id, body: rows.headers.join("\t"))
    rows.each do |row|
      row_num += 1
      import_result = AgentImportResult.create!(agent_import_file_id: id, body: row.fields.join("\t"))
      next if row['dummy'].to_s.strip.present?

      agent = Agent.new
      agent = set_agent_value(agent, row)

      if agent.save!
        import_result.agent = agent
        num[:agent_imported] += 1
      end

      import_result.save!
    end
    Sunspot.commit
    rows.close
    transition_to!(:completed)
    mailer = AgentImportMailer.completed(self)
    send_message(mailer)
    num
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    mailer = AgentImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def self.import
    AgentImportFile.not_imported.each do |file|
      file.import_start
    end
  rescue StandardError
    Rails.logger.info "#{Time.zone.now} importing agents failed!"
  end

  def modify
    transition_to!(:started)
    rows = open_import_file
    rows.shift
    row_num = 1

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?

      agent = Agent.find_by(id: row['id'])
      next unless agent

      agent.full_name = row['full_name'] if row['full_name'].to_s.strip.present?
      agent.full_name_transcription = row['full_name_transcription'] if row['full_name_transcription'].to_s.strip.present?
      agent.first_name = row['first_name'] if row['first_name'].to_s.strip.present?
      agent.first_name_transcription = row['first_name_transcription'] if row['first_name_transcription'].to_s.strip.present?
      agent.middle_name = row['middle_name'] if row['middle_name'].to_s.strip.present?
      agent.middle_name_transcription = row['middle_name_transcription'] if row['middle_name_transcription'].to_s.strip.present?
      agent.last_name = row['last_name'] if row['last_name'].to_s.strip.present?
      agent.last_name_transcription = row['last_name_transcription'] if row['last_name_transcription'].to_s.strip.present?
      agent.address_1 = row['address_1'] if row['address_1'].to_s.strip.present?
      agent.address_2 = row['address_2'] if row['address_2'].to_s.strip.present?
      agent.save!
    end
    transition_to!(:completed)
    mailer = AgentImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    mailer = AgentImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  def remove
    transition_to!(:started)
    rows = open_import_file
    rows.shift
    row_num = 1

    rows.each do |row|
      row_num += 1
      next if row['dummy'].to_s.strip.present?

      agent = Agent.find_by(id: row['id'].to_s.strip)
      next unless agent

      agent.picture_files.destroy_all
      agent.reload
      agent.destroy
    end
    transition_to!(:completed)
    mailer = AgentImportMailer.completed(self)
    send_message(mailer)
  rescue StandardError => e
    self.error_message = "line #{row_num}: #{e.message}"
    transition_to!(:failed)
    mailer = AgentImportMailer.failed(self)
    send_message(mailer)
    raise e
  end

  private

  def open_import_file
    tempfile = Tempfile.new(self.class.name.underscore)
    tempfile.puts(convert_encoding(attachment.download))
    tempfile.close

    file = CSV.open(tempfile, col_sep: "\t")
    header = file.first
    rows = CSV.open(tempfile, headers: header, col_sep: "\t")
    tempfile.close(true)
    file.close
    rows
  end

  def set_agent_value(agent, row)
    agent.first_name = row['first_name'] if row['first_name']
    agent.middle_name = row['middle_name'] if row['middle_name']
    agent.last_name = row['last_name'] if row['last_name']
    agent.first_name_transcription = row['first_name_transcription'] if row['first_name_transcription']
    agent.middle_name_transcription = row['middle_name_transcription'] if row['middle_name_transcription']
    agent.last_name_transcription = row['last_name_transcription'] if row['last_name_transcription']

    agent.full_name = row['full_name'] if row['full_name']
    agent.full_name_transcription = row['full_name_transcription'] if row['full_name_transcription']

    agent.address_1 = row['address_1'] if row['address_1']
    agent.address_2 = row['address_2'] if row['address_2']
    agent.zip_code_1 = row['zip_code_1'] if row['zip_code_1']
    agent.zip_code_2 = row['zip_code_2'] if row['zip_code_2']
    agent.telephone_number_1 = row['telephone_number_1'] if row['telephone_number_1']
    agent.telephone_number_2 = row['telephone_number_2'] if row['telephone_number_2']
    agent.fax_number_1 = row['fax_number_1'] if row['fax_number_1']
    agent.fax_number_2 = row['fax_number_2'] if row['fax_number_2']
    agent.note = row['note'] if row['note']
    agent.birth_date = row['birth_date'] if row['birth_date']
    agent.death_date = row['death_date'] if row['death_date']

    # if row['username'].to_s.strip.blank?
    agent.email = row['email'].to_s.strip
    agent.required_role = Role.find_by(name: row['required_role'].to_s.strip.camelize) || Role.find_by(name: 'Guest')
    # else
    #   agent.required_role = Role.where(name: row['required_role'].to_s.strip.camelize).first || Role.where('Librarian').first
    # end
    language = Language.find_by(name: row['language'].to_s.strip.camelize) || Language.find_by(iso_639_2: row['language'].to_s.strip.downcase) || Language.find_by(iso_639_1: row['language'].to_s.strip.downcase)
    agent.language = language if language
    country = Country.find_by(name: row['country'].to_s.strip)
    agent.country = country if country
    agent
  end
end

# == Schema Information
#
# Table name: agent_import_files
#
#  id                        :bigint           not null, primary key
#  parent_id                 :bigint
#  content_type              :string
#  size                      :integer
#  user_id                   :bigint
#  note                      :text
#  executed_at               :datetime
#  agent_import_file_name    :string
#  agent_import_content_type :string
#  agent_import_file_size    :integer
#  agent_import_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  agent_import_fingerprint  :string
#  error_message             :text
#  edit_mode                 :string
#  user_encoding             :string
#
