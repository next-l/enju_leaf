# -*- encoding: utf-8 -*-
require 'rails_helper'

describe Answer do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: answers
#
#  id                   :integer          not null, primary key
#  user_id              :integer          not null
#  question_id          :integer          not null
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#  deleted_at           :datetime
#  shared               :boolean          default(TRUE), not null
#  state                :string
#  item_identifier_list :text
#  url_list             :text
#
