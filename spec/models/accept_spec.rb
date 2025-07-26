require 'rails_helper'

describe Accept do
  fixtures :all

  it "should change circulation_status" do
    expect(items(:item_00012).circulation_status.name).to eq 'Circulation Status Undefined'
    expect(items(:item_00012).use_restriction.name).to eq 'Not For Loan'

    accept = FactoryBot.create(:accept, item: items(:item_00012))
    expect(accept.item.circulation_status.name).to eq 'Available On Shelf'
    expect(accept.item.use_restriction.name).to eq 'Limited Circulation, Normal Loan Period'
  end
end

# == Schema Information
#
# Table name: accepts
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  basket_id    :bigint
#  item_id      :bigint
#  librarian_id :bigint
#
# Indexes
#
#  index_accepts_on_basket_id     (basket_id)
#  index_accepts_on_item_id       (item_id) UNIQUE
#  index_accepts_on_librarian_id  (librarian_id)
#
