# -*- encoding: utf-8 -*-
class Patron < ActiveRecord::Base
  scope :readable_by, lambda{|user| {:conditions => ['required_role_id <= ?', user.try(:user_has_role).try(:role_id) || Role.where(:name => 'Guest').select(:id).first.id]}}
  has_many :creates, :dependent => :destroy
  has_many :works, :through => :creates
  has_many :realizes, :dependent => :destroy
  has_many :expressions, :through => :realizes
  has_many :produces, :dependent => :destroy
  has_many :manifestations, :through => :produces
  has_many :children, :foreign_key => 'parent_id', :class_name => 'PatronRelationship', :dependent => :destroy
  has_many :parents, :foreign_key => 'child_id', :class_name => 'PatronRelationship', :dependent => :destroy
  has_many :derived_patrons, :through => :children, :source => :child
  has_many :original_patrons, :through => :parents, :source => :parent
  has_many :picture_files, :as => :picture_attachable, :dependent => :destroy
  has_many :donates
  has_many :donated_items, :through => :donates, :source => :item
  has_many :owns, :dependent => :destroy
  has_many :items, :through => :owns
  if defined?(EnjuResourceMerge)
    has_many :patron_merges, :dependent => :destroy
    has_many :patron_merge_lists, :through => :patron_merges
  end
  belongs_to :user
  belongs_to :patron_type
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  belongs_to :language
  belongs_to :country
  has_one :patron_import_result

  validates_presence_of :language, :patron_type, :country
  validates_associated :language, :patron_type, :country
  validates :full_name, :presence => true, :length => {:maximum => 255}
  validates :user_id, :uniqueness => true, :allow_nil => true
  validates :birth_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
  validates :death_date, :format => {:with => /^\d+(-\d{0,2}){0,2}$/}, :allow_blank => true
  validates :email, :format => {:with => /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i}, :allow_blank => true
  validate :check_birth_date
  before_validation :set_role_and_name, :on => :create
  before_save :set_date_of_birth, :set_date_of_death

  has_paper_trail
  attr_accessor :user_username
  #[:address_1, :address_2].each do |column|
  #  encrypt_with_public_key column,
  #    :key_pair => File.join(Rails.root.to_s,'config','keypair.pem'),
  #    :base64 => true
  #end

  searchable do
    text :name, :place, :address_1, :address_2, :other_designation, :note
    string :zip_code_1
    string :zip_code_2
    string :username do
      user.username if user
    end
    time :created_at
    time :updated_at
    time :date_of_birth
    time :date_of_death
    string :user
    integer :work_ids, :multiple => true
    integer :expression_ids, :multiple => true
    integer :manifestation_ids, :multiple => true
    integer :patron_merge_list_ids, :multiple => true if defined?(EnjuResourceMerge)
    integer :original_patron_ids, :multiple => true
    integer :required_role_id
    integer :patron_type_id
  end

  def self.per_page
    10
  end

  def full_name_without_space
    full_name.gsub(/\s/, "")
  end

  def set_role_and_name
    self.required_role = Role.where(:name => 'Librarian').first if self.required_role_id.nil?
    set_full_name
  end

  def set_full_name
    if self.full_name.blank?
      if self.last_name.to_s.strip and self.first_name.to_s.strip and configatron.family_name_first == true
        self.full_name = [last_name, middle_name, first_name].compact.join(" ").to_s.strip
      else
        self.full_name = [first_name, last_name, middle_name].compact.join(" ").to_s.strip
      end
    end
    if self.full_name_transcription.blank?
      self.full_name_transcription = [last_name_transcription, middle_name_transcription, first_name_transcription].join(" ").to_s.strip
    end
    [self.full_name, self.full_name_transcription]
  end

  def set_date_of_birth
    return if birth_date.blank?
    begin
      date = Time.zone.parse("#{birth_date}")
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{birth_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{birth_date}-01-01")
        rescue
          nil
        end
      end
    end
    self.date_of_birth = date
  end

  def set_date_of_death
    return if death_date.blank?
    begin
      date = Time.zone.parse("#{death_date}")
    rescue ArgumentError
      begin
        date = Time.zone.parse("#{death_date}-01")
      rescue ArgumentError
        begin
          date = Time.zone.parse("#{death_date}-01-01")
        rescue
          nil
        end
      end
    end

    self.date_of_death = date
  end

  def check_birth_date
    if date_of_birth.present? and date_of_death.present?
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
    full_name.gsub(/\s/, "")
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
    #name << full_name_without_space
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

  def check_required_role(user)
    return true if self.user.blank?
    return true if self.user.required_role.name == 'Guest'
    return true if user == self.user
    return true if user.has_role?(self.user.required_role.name)
    false
  rescue NoMethodError
    false
  end

  def created(work)
    creates.where(:work_id => work.id).first
  end

  def realized(expression)
    realizes.where(:expression_id => expression.id).first
  end

  def produced(manifestation)
    produces.where(:manifestation_id => manifestation.id).first
  end

  def owned(item)
    owns.where(:item_id => item.id)
  end

  def self.import_patrons(patron_lists)
    list = []
    patron_lists.each do |patron_list|
      patron = Patron.where(:full_name => patron_list[:full_name]).first
      unless patron
        patron = Patron.new(
          :full_name => patron_list[:full_name],
          :full_name_transcription => patron_list[:full_name_transcription],
          :language_id => 1
        )
        patron.required_role = Role.where(:name => 'Guest').first
        patron.save
      end
      list << patron
    end
    list
  end

  def patrons
    self.original_patrons + self.derived_patrons
  end
end







# == Schema Information
#
# Table name: patrons
#
#  id                                  :integer         not null, primary key
#  user_id                             :integer
#  last_name                           :string(255)
#  middle_name                         :string(255)
#  first_name                          :string(255)
#  last_name_transcription             :string(255)
#  middle_name_transcription           :string(255)
#  first_name_transcription            :string(255)
#  corporate_name                      :string(255)
#  corporate_name_transcription        :string(255)
#  full_name                           :string(255)
#  full_name_transcription             :text
#  full_name_alternative               :text
#  created_at                          :datetime
#  updated_at                          :datetime
#  deleted_at                          :datetime
#  zip_code_1                          :string(255)
#  zip_code_2                          :string(255)
#  address_1                           :text
#  address_2                           :text
#  address_1_note                      :text
#  address_2_note                      :text
#  telephone_number_1                  :string(255)
#  telephone_number_2                  :string(255)
#  fax_number_1                        :string(255)
#  fax_number_2                        :string(255)
#  other_designation                   :text
#  place                               :text
#  street                              :text
#  locality                            :text
#  region                              :text
#  date_of_birth                       :datetime
#  date_of_death                       :datetime
#  language_id                         :integer         default(1), not null
#  country_id                          :integer         default(1), not null
#  patron_type_id                      :integer         default(1), not null
#  lock_version                        :integer         default(0), not null
#  note                                :text
#  required_role_id                    :integer         default(1), not null
#  required_score                      :integer         default(0), not null
#  state                               :string(255)
#  email                               :text
#  url                                 :text
#  full_name_alternative_transcription :text
#  title                               :string(255)
#  birth_date                          :string(255)
#  death_date                          :string(255)
#

