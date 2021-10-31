class Classification < ApplicationRecord
  belongs_to :classification_type
  belongs_to :manifestation, touch: true, optional: true

  validates_associated :classification_type
  validates_presence_of :category, :classification_type
  searchable do
    text :category, :note
    integer :classification_type_id
  end
  strip_attributes only: [:category, :url]

  paginates_per 10
end

# == Schema Information
#
# Table name: classifications
#
#  id                     :integer          not null, primary key
#  parent_id              :integer
#  category               :string           not null
#  note                   :text
#  classification_type_id :integer          not null
#  created_at             :datetime
#  updated_at             :datetime
#  lft                    :integer
#  rgt                    :integer
#  manifestation_id       :integer
#  url                    :string
#  label                  :string
#
