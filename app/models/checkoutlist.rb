class Checkoutlist < ActiveRecord::Base
  def self.per_page
    10
  end
end
