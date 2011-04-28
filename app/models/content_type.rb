class ContentType < ActiveRecord::Base
  include MasterModel
  has_many :manifestations
end
