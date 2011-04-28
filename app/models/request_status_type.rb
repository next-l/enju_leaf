class RequestStatusType < ActiveRecord::Base
  include MasterModel
  has_many :reserves
end
