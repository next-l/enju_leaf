require 'rails_helper'

describe InventoryFile do
  fixtures :users

  before(:each) do
    @file = InventoryFile.create(user: users(:admin), shelf: Shelf.find_by(name: 'first_shelf'))
    @file.attachment.attach(io: File.new("#{Rails.root.to_s}/spec/fixtures/files/inventory_file_sample.tsv"), filename: 'attachment.txt')
  end

  it "should be imported" do
    expect(@file.import).to be_truthy
  end

  it "should export results" do
    expect(@file.export).to be_truthy
  end
end

# == Schema Information
#
# Table name: inventory_files
#
#  id                     :bigint           not null, primary key
#  content_type           :string
#  filename               :string
#  inventory_content_type :string
#  inventory_file_name    :string
#  inventory_file_size    :integer
#  inventory_fingerprint  :string
#  inventory_updated_at   :datetime
#  note                   :text
#  size                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :bigint
#  user_id                :bigint
#
# Indexes
#
#  index_inventory_files_on_shelf_id  (shelf_id)
#  index_inventory_files_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (shelf_id => shelves.id)
#  fk_rails_...  (user_id => users.id)
#
