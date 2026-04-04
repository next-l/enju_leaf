class Color < ApplicationRecord
  belongs_to :library_group
  validates :code, presence: true, format: /\A[A-Fa-f0-9]{6}\Z/
  validates :property, presence: true, uniqueness: true, format: /\A[a-z][0-9a-z_]*[0-9a-z]\Z/

  acts_as_list
end
