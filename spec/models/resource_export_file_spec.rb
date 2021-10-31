require 'rails_helper'
  
describe ResourceExportFile do
  fixtures :all
  
  it "should export in background" do
    file = ResourceExportFile.new
    file.user = users(:admin)
    file.save
    ResourceExportFileJob.perform_later(file).should be_truthy
  end

  it "should respect the role of the user" do
    message_count = Message.count
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    file = export_file.resource_export
    lines = File.open(file.path).readlines.map(&:chomp)
    columns = lines.first.split(/\t/)
    expect(columns).to include "bookstore"
    expect(columns).to include "budget_type"
    expect(columns).to include "item_price"
    Message.count.should eq message_count + 1
    Message.order(:created_at).last.subject.should eq "Export completed: #{export_file.id}"
  end

  it "should export custom identifier's value" do
    manifestation = FactoryBot.create(:manifestation)
    custom = IdentifierType.find_by(name: "custom")
    identifier = FactoryBot.create(:identifier, identifier_type: custom, body: "a11223344")
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    file = export_file.resource_export
    expect(file).to be_truthy
    lines = File.open(file.path).readlines.map(&:chomp)
    expect(lines.first.split(/\t/)).to include "identifier:custom"
    expect(lines.last.split(/\t/)).to include "a11223344"
  end

  it "should export carrier_type" do
    carrier_type = FactoryBot.create(:carrier_type)
    manifestation = FactoryBot.create(:manifestation, carrier_type: carrier_type)
    manifestation.save!
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    file = export_file.resource_export
    CSV.open(file.path, {headers: true, col_sep: "\t"}).each do |row|
      expect(row).to have_key "carrier_type"
      case row["manifestation_id"].to_i
      when 1
        expect(row["carrier_type"]).to eq "volume"
      when manifestation.id
        expect(row["carrier_type"]).to eq carrier_type.name
      end
    end
  end

  it "should export create_type, realize_type and produce_type" do
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    file = export_file.resource_export
    CSV.open(file.path, {headers: true, col_sep: "\t"}).each do |row|
      manifestation = Manifestation.find(row['manifestation_id'])
      manifestation.creates.each do |create|
        if create.create_type
          expect(row['creator']).to match "#{create.agent.full_name}||#{create.create_type.name}"
        end
      end

      manifestation.realizes.each do |realize|
        if realize.realize_type
          expect(row['contributor']).to match "#{realize.agent.full_name}||#{realize.realize_type.name}"
        end
      end

      manifestation.produces.each do |produce|
        if produce.produce_type
          expect(row['publisher']).to match "#{produce.agent.full_name}||#{produce.produce_type.name}"
        end
      end
    end
  end

  it "should export custom properties" do
    item = FactoryBot.create(:item)
    3.times do
      item.manifestation.manifestation_custom_values << FactoryBot.build(:manifestation_custom_value)
    end
    3.times do
      item.item_custom_values << FactoryBot.build(:item_custom_value)
    end
    export_file = ResourceExportFile.new
    export_file.user = users(:admin)
    export_file.save!
    export_file.export!
    file = export_file.resource_export
    CSV.open(file.path, {headers: true, col_sep: "\t"}).each do |row|
      if row['manifestation_id'] == item.manifestation.id
        item.manifestation_custom_values.each do |value|
          expect(row).to have_key "manifestation:#{value.manifestation_custom_property.name}"
          expect(row["manifestation:#{value.manifestation_custom_property.name}"]).to eq value
        end
        item.item_custom_values.each do |value|
          expect(row).to have_key "item:#{value.item_custom_property.name}"
          expect(row["item:#{value.item_custom_property.name}"]).to eq value
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: resource_export_files
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  resource_export_file_name    :string
#  resource_export_content_type :string
#  resource_export_file_size    :bigint
#  resource_export_updated_at   :datetime
#  executed_at                  :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#
