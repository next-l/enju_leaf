class License < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
end
