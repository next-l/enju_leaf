# -*- encoding: utf-8 -*-
require 'timeout'
class Question < ActiveRecord::Base
  default_scope :order => 'id DESC'
  scope :public_questions, where(:shared => true)
  scope :private_questions, where(:shared => false)
  belongs_to :user, :counter_cache => true, :validate => true
  has_many :answers, :dependent => :destroy

  validates_associated :user
  validates_presence_of :user, :body
  #acts_as_soft_deletable
  searchable do
    text :body, :answer_body
    string :username
    time :created_at
    time :updated_at do
      last_updated_at
    end
    boolean :shared
    boolean :solved
    integer :answers_count
    integer :manifestation_id, :multiple => true do
      answers.collect(&:items).flatten.collect{|i| i.manifestation.id}
    end
  end

  acts_as_taggable_on :tags
  enju_ndl
 
  def self.per_page
    10
  end

  def self.crd_per_page
    5
  end

  def answer_body
    text = ""
    self.reload
    self.answers.each do |answer|
      text += answer.body
    end
    return text
  end

  def username
    self.user.username
  end

  def last_updated_at
    if answers.last
      time = answers.last.updated_at
    end
    if time
      if time > updated_at
        time
      else
        updated_at
      end
    else
      updated_at
    end
  end

end
