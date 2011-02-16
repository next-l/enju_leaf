# -*- encoding: utf-8 -*-
class Answer < ActiveRecord::Base
  default_scope :order => 'id ASC'
  scope :public_answers, where(:shared => true)
  scope :private_answers, where(:shared => false)
  belongs_to :user, :counter_cache => true, :validate => true
  belongs_to :question, :counter_cache => true, :validate => true
  has_many :answer_has_items, :dependent => :destroy
  has_many :items, :through => :answer_has_items

  #acts_as_soft_deletable
  after_save :save_questions
  before_save :add_items

  validates_associated :user, :question
  validates_presence_of :user, :question, :body

  def self.per_page
    10
  end

  def save_questions
    self.question.save
  end

  def add_items
    item_list = item_identifier_list.to_s.strip.split.map{|i| Item.first(:conditions => {:item_identifier => i})}.compact.uniq
    url_list = add_urls
    self.items = item_list + url_list
  end

  def add_urls
    list = url_list.to_s.strip.split.map{|u| Manifestation.first(:conditions => {:access_address => URI.parse(u).normalize.to_s})}.compact.map{|m| m.web_item}.compact.uniq
  end

end
