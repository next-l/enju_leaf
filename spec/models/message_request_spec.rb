# -*- encoding: utf-8 -*-
require 'spec_helper'

describe MessageRequest do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: message_requests
#
#  id                  :integer         not null, primary key
#  sender_id           :integer
#  receiver_id         :integer
#  message_template_id :integer
#  sent_at             :datetime
#  deleted_at          :datetime
#  body                :text
#  state               :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

