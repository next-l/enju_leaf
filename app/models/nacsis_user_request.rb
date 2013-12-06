# encoding: utf-8

class NacsisUserRequest < ActiveRecord::Base
  attr_accessible :user_note

  belongs_to :user, :validate => true

  validates :user_id, :presence => true
  validates :user, :associated => true, :presence => true

  VALID_REQUEST_TYPES = [1, 2]
  validates :request_type, :presence => true, :inclusion => VALID_REQUEST_TYPES

  VALID_STATES = [0, 1, 2, 3, 4, 5, 6, 7, 8]
  validates :state, :presence => true, :inclusion => VALID_STATES

  searchable do
    integer :state
    integer :request_type
    string :ncid
    time :created_at
    text :subject_heading, :author_heading
    string :subject_heading # ソート用
    string :user_number do # ソート用
      user.user_number
    end
    integer :user_id
  end
end
