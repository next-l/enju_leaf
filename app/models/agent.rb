class Agent < ApplicationRecord
  include EnjuNdl::EnjuAgent

  scope :readable_by, lambda{ |user|
    if user
      where('required_role_id <= ?', user.try(:user_has_role).try(:role_id))
    else
      where('required_role_id <= 1')
    end
  }
  has_many :creates, dependent: :destroy
  has_many :works, through: :creates
  has_many :realizes, dependent: :destroy
  has_many :expressions, through: :realizes
  has_many :produces, dependent: :destroy
  has_many :manifestations, through: :produces
  has_many :children, foreign_key: 'parent_id', class_name: 'AgentRelationship', dependent: :destroy, inverse_of: :parent
  has_many :parents, foreign_key: 'child_id', class_name: 'AgentRelationship', dependent: :destroy, inverse_of: :child
  has_many :derived_agents, through: :children, source: :child
  has_many :original_agents, through: :parents, source: :parent
  has_many :picture_files, as: :picture_attachable, dependent: :destroy
  has_many :donates, dependent: :destroy
  has_many :donated_items, through: :donates, source: :item
  has_many :owns, dependent: :destroy
  has_many :items, through: :owns
  has_many :agent_merges, dependent: :destroy
  has_many :agent_merge_lists, through: :agent_merges
  belongs_to :agent_type
  belongs_to :required_role, class_name: 'Role'
  belongs_to :language
  belongs_to :country
  has_one :agent_import_result
  belongs_to :profile, optional: true

  validates :full_name, presence: true, length: { maximum: 255 }
  validates :birth_date, format: { with: /\A\d+(-\d{0,2}){0,2}\z/ }, allow_blank: true
  validates :death_date, format: { with: /\A\d+(-\d{0,2}){0,2}\z/ }, allow_blank: true
  validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }, allow_blank: true
  validate :check_birth_date
  before_validation :set_role_and_name, on: :create
  before_save :set_date_of_birth, :set_date_of_death
  after_save do |agent|
    agent.works.map{|work| work.touch && work.index}
    agent.expressions.map{|expression| expression.touch && expression.index}
    agent.manifestations.map{|manifestation| manifestation.touch && manifestation.index}
    agent.items.map{|item| item.touch && item.index}
    Sunspot.commit
  end
  after_destroy do |agent|
    agent.works.map{|work| work.touch && work.index}
    agent.expressions.map{|expression| expression.touch && expression.index}
    agent.manifestations.map{|manifestation| manifestation.touch && manifestation.index}
    agent.items.map{|item| item.touch && item.index}
    Sunspot.commit
  end

  attr_accessor :agent_id

  searchable do
    text :name, :place, :address_1, :address_2, :other_designation, :note
    string :zip_code_1
    string :zip_code_2
    time :created_at
    time :updated_at
    time :date_of_birth
    time :date_of_death
    integer :work_ids, multiple: true
    integer :expression_ids, multiple: true
    integer :manifestation_ids, multiple: true
    integer :agent_merge_list_ids, multiple: true
    integer :original_agent_ids, multiple: true
    integer :required_role_id
    integer :agent_type_id
  end

  paginates_per 10

  def set_role_and_name
    self.required_role = Role.find_by(name: 'Librarian') if required_role_id.nil?
    set_full_name
  end

  def set_full_name
    if full_name.blank?
      if LibraryGroup.site_config.family_name_first
        self.full_name = [last_name, middle_name, first_name].compact.join(" ").to_s.strip
      else
        self.full_name = [first_name, last_name, middle_name].compact.join(" ").to_s.strip
      end
    end
    if full_name_transcription.blank?
      self.full_name_transcription = [last_name_transcription, middle_name_transcription, first_name_transcription].join(" ").to_s.strip
    end
    [full_name, full_name_transcription]
  end

  def set_date_of_birth
    return if birth_date.blank?

    begin
      date = Time.zone.parse(birth_date.to_s)
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{birth_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{birth_date}-01-01")
        rescue StandardError
          nil
        end
      end
    end
    self.date_of_birth = date
  end

  def set_date_of_death
    return if death_date.blank?

    begin
      date = Time.zone.parse(death_date.to_s)
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{death_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{death_date}-01-01")
        rescue StandardError
          nil
        end
      end
    end

    self.date_of_death = date
  end

  def check_birth_date
    if date_of_birth.present? && date_of_death.present?
      if date_of_birth > date_of_death
        errors.add(:birth_date)
        errors.add(:death_date)
      end
    end
  end

  #def full_name_generate
  #  # TODO: 日本人以外は？
  #  name = []
  #  name << self.last_name.to_s.strip
  #  name << self.middle_name.to_s.strip unless self.middle_name.blank?
  #  name << self.first_name.to_s.strip
  #  name << self.corporate_name.to_s.strip
  #  name.join(" ").strip
  #end

  def full_name_without_space
    full_name.gsub(/[\s,]/, "")
  #  # TODO: 日本人以外は？
  #  name = []
  #  name << self.last_name.to_s.strip
  #  name << self.middle_name.to_s.strip
  #  name << self.first_name.to_s.strip
  #  name << self.corporate_name.to_s.strip
  #  name.join("").strip
  end

  def full_name_transcription_without_space
    full_name_transcription.to_s.gsub(/\s/, "")
  end

  def full_name_alternative_without_space
    full_name_alternative.to_s.gsub(/\s/, "")
  end

  def name
    name = []
    name << full_name.to_s.strip
    name << full_name_transcription.to_s.strip
    name << full_name_alternative.to_s.strip
    name << full_name_without_space
    #name << full_name_transcription_without_space
    #name << full_name_alternative_without_space
    #name << full_name.wakati rescue nil
    #name << full_name_transcription.wakati rescue nil
    #name << full_name_alternative.wakati rescue nil
    name
  end

  def date
    if date_of_birth
      if date_of_death
        "#{date_of_birth} - #{date_of_death}"
      else
        "#{date_of_birth} -"
      end
    end
  end

  def creator?(resource)
    resource.creators.include?(self)
  end

  def publisher?(resource)
    resource.publishers.include?(self)
  end

  def created(work)
    creates.find_by(work_id: work.id)
  end

  def realized(expression)
    realizes.find_by(expression_id: expression.id)
  end

  def produced(manifestation)
    produces.find_by(manifestation_id: manifestation.id)
  end

  def owned(item)
    owns.where(item_id: item.id)
  end

  def self.import_agents(agent_lists)
    agents = []
    agent_lists.each do |agent_list|
      name_and_role = agent_list[:full_name].split('||')
      if agent_list[:agent_identifier].present?
        agent = Agent.find_by(agent_identifier: agent_list[:agent_identifier])
      else
        agents_matched = Agent.where(full_name: name_and_role[0])
        agents_matched = agents_matched.where(place: agent_list[:place]) if agent_list[:place]
        agent = agents_matched.first
      end
      role_type = name_and_role[1].to_s.strip
      unless agent
        agent = Agent.new(
          full_name: name_and_role[0],
          full_name_transcription: agent_list[:full_name_transcription],
          agent_identifier: agent_list[:agent_identifier],
          place: agent_list[:place],
          language_id: 1
        )
        agent.required_role = Role.find_by(name: 'Guest')
        agent.save
      end
      agents << agent
    end
    agents.uniq!
    agents
  end

  def agents
    original_agents + derived_agents
  end

  def self.new_agents(agents_params)
    return [] unless agents_params

    agents = []
    Agent.transaction do
      agents_params.each do |k, v|
        next if v['_destroy'] == '1'

        agent = nil

        if v['agent_id'].present?
          agent = Agent.find(v['agent_id'])
        elsif v['id'].present?
          agent = Agent.find(v['id'])
        end

        if !agent or agent.full_name != v['full_name']
          v.delete('id')
          v.delete('agent_id')
          v.delete('_destroy')
          agent = Agent.create(v)
        end

        agents << agent
      end
    end

    agents
  end
end

# == Schema Information
#
# Table name: agents
#
#  id                                  :bigint           not null, primary key
#  last_name                           :string
#  middle_name                         :string
#  first_name                          :string
#  last_name_transcription             :string
#  middle_name_transcription           :string
#  first_name_transcription            :string
#  corporate_name                      :string
#  corporate_name_transcription        :string
#  full_name                           :string
#  full_name_transcription             :text
#  full_name_alternative               :text
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  zip_code_1                          :string
#  zip_code_2                          :string
#  address_1                           :text
#  address_2                           :text
#  address_1_note                      :text
#  address_2_note                      :text
#  telephone_number_1                  :string
#  telephone_number_2                  :string
#  fax_number_1                        :string
#  fax_number_2                        :string
#  other_designation                   :text
#  place                               :text
#  postal_code                         :string
#  street                              :text
#  locality                            :text
#  region                              :text
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  language_id                         :bigint           default(1), not null
#  country_id                          :bigint           default(1), not null
#  agent_type_id                       :bigint           default(1), not null
#  lock_version                        :integer          default(0), not null
#  note                                :text
#  required_role_id                    :bigint           default(1), not null
#  required_score                      :integer          default(0), not null
#  email                               :text
#  url                                 :text
#  full_name_alternative_transcription :text
#  birth_date                          :string
#  death_date                          :string
#  agent_identifier                    :string
#  profile_id                          :bigint
#
