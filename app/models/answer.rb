# -*- encoding: utf-8 -*-
class Answer < ActiveRecord::Base
  attr_accessible :question_id, :body, :item_identifier_list, :url_list

  default_scope :order => 'id ASC'
  scope :public_answers, where(:shared => true)
  scope :private_answers, where(:shared => false)
  belongs_to :user, :counter_cache => true, :validate => true
  belongs_to :question, :counter_cache => true # , :validate => true
  has_many :answer_has_items, :dependent => :destroy
  has_many :items, :through => :answer_has_items

  after_save :save_questions
  before_save :add_items

  validates_associated :user #, :question
  validates_presence_of :body
#  validates_presence_of :user, :question, :body
  validate :check_url_list

  paginates_per 10

  def save_questions
    self.question.save
  end

  def add_items
    item_list = item_identifier_list.to_s.strip.split.map{|i| Item.where(:item_identifier => i).first}.compact.uniq
    url_list = add_urls
    self.items = item_list + url_list
  end

  def add_urls
    list = url_list.to_s.strip.split.map{|u| Manifestation.where(:access_address => Addressable::URI.parse(u).normalize.to_s).first}.compact.map{|m| m.web_item}.compact.uniq
  end

  def check_url_list
    url_list.to_s.strip.split.each do |url|
      errors.add(:url_list) unless Addressable::URI.parse(url).host
    end
  end
end

# == Schema Information
#
# Table name: answers
#
#  id                   :integer         not null, primary key
#  user_id              :integer         not null
#  question_id          :integer         not null
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#  deleted_at           :datetime
#  shared               :boolean         default(TRUE), not null
#  state                :string(255)
#  item_identifier_list :text
#  url_list             :text
#

