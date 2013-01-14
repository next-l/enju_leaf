class Department < ActiveRecord::Base
  attr_accessible :name, :display_name, :short_name

  validates_uniqueness_of :name
  validates_presence_of :name, :display_name
  validates_format_of :name, :with => /^[0-9A-Za-z]/ #, :message =>"は半角英数字で入力してください。"

end
