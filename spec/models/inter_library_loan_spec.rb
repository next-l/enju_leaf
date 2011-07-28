# -*- encoding: utf-8 -*-
require 'spec_helper'

describe InterLibraryLoan do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: inter_library_loans
#
#  id                   :integer         not null, primary key
#  item_id              :integer         not null
#  borrowing_library_id :integer         not null
#  requested_at         :datetime
#  shipped_at           :datetime
#  received_at          :datetime
#  return_shipped_at    :datetime
#  return_received_at   :datetime
#  deleted_at           :datetime
#  state                :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#

