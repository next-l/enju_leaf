# -*- encoding: utf-8 -*-
require 'spec_helper'

describe PurchaseRequest do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: purchase_requests
#
#  id                  :integer         not null, primary key
#  user_id             :integer         not null
#  title               :text            not null
#  author              :text
#  publisher           :text
#  isbn                :string(255)
#  date_of_publication :datetime
#  price               :integer
#  url                 :string(255)
#  note                :text
#  accepted_at         :datetime
#  denied_at           :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  state               :string(255)
#  pub_date            :string(255)
#

