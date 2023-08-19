require 'rails_helper'

describe PurchaseRequest do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: purchase_requests
#
#  id                  :bigint           not null, primary key
#  user_id             :bigint           not null
#  title               :text             not null
#  author              :text
#  publisher           :text
#  isbn                :string
#  date_of_publication :datetime
#  price               :integer
#  url                 :string
#  note                :text
#  accepted_at         :datetime
#  denied_at           :datetime
#  state               :string
#  pub_date            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
