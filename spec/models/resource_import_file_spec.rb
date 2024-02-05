require 'rails_helper'
  
describe ResourceImportFile do
  fixtures :all
  
  describe "when its mode is 'create'" do
    describe "when it is written in utf-8" do
      before(:each) do
        @file = ResourceImportFile.create(
          attachment: fixture_file_upload("resource_import_file_sample1.tsv"),
          default_shelf_id: 3,
          user: users(:admin),
          edit_mode: 'create'
        )
      end

      it "should be imported", vcr: true do
        old_manifestations_count = Manifestation.count
        old_items_count = Item.count
        old_agents_count = Agent.count
        old_import_results_count = ResourceImportResult.count
        old_message_count = Message.count

        @file.import_start.should eq({manifestation_imported: 10, item_imported: 10, manifestation_found: 6, item_found: 3, failed: 7})
        manifestation = Item.find_by(item_identifier: '11111').manifestation
        manifestation.publishers.first.full_name.should eq 'test4'
        manifestation.publishers.first.full_name_transcription.should eq 'てすと4'
        manifestation.publishers.second.full_name_transcription.should eq 'てすと5'
        manifestation.produces.first.produce_type.name.should eq 'publisher'
        manifestation.creates.first.create_type.name.should eq 'author'
        expect(manifestation.issn_records.pluck(:body)).to eq ['03875806']
        Manifestation.count.should eq old_manifestations_count + 10
        Item.count.should eq old_items_count + 10
        Agent.count.should eq old_agents_count + 9
        @file.resource_import_results.order(:id).first.body.split("\t").first.should eq 'imported_manifestation_id'
        ResourceImportResult.count.should eq old_import_results_count + 23

        manifestation_101 = Manifestation.find_by(manifestation_identifier: '101')
        manifestation_101.series_statements.count.should eq 1
        manifestation_101.series_statements.first.original_title.should eq '主シリーズ'
        manifestation_101.series_statements.first.title_transcription.should eq 'しゅしりーず'
        manifestation_101.series_statements.first.title_subseries.should eq '副シリーズ'
        manifestation_101.series_statements.first.title_subseries_transcription.should eq 'ふくしりーず'
        manifestation_101.items.order(:id).last.call_number.should eq '007|A'
        manifestation_101.serial.should be_falsy
        expect(manifestation_101.required_role.name).to eq 'Administrator'

        item_10101 = Item.find_by(item_identifier: '10101')
        item_10101.manifestation.creators.size.should eq 2
        item_10101.manifestation.creates.order(:id).first.create_type.name.should eq 'author'
        item_10101.manifestation.creates.order(:id).second.agent.full_name.should eq 'test1'
        item_10101.manifestation.creates.order(:id).second.create_type.name.should eq 'illustrator'
        item_10101.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        item_10101.budget_type.name.should eq 'Public fund'
        item_10101.bookstore.name.should eq 'Example store'
        item_10101.manifestation.classifications.count.should eq 1
        item_10101.manifestation.classifications.first.classification_type.name.should eq 'ndc9'
        item_10101.manifestation.classifications.first.category.should eq '007'
        item_10101.manifestation.language.name.should eq 'Japanese'
        item_10101.manifestation.statement_of_responsibility.should eq '著者A; 著者B'
        item_10101.binding_item_identifier.should eq '9001'
        item_10101.binding_call_number.should eq '330|A'
        item_10101.binded_at.should eq Time.zone.parse('2014-08-16')
        item_10101.manifestation.publication_place.should eq '東京'
        item_10101.include_supplements.should eq true
        item_10101.note.should eq 'カバーなし'
        item_10101.url.should eq 'http://example.jp/item/1'
        item_10101.manifestation.carrier_type.name.should eq 'volume'
        item_10101.manifestation.manifestation_content_type.name.should eq 'text'
        item_10101.manifestation.frequency.name.should eq 'monthly'
        item_10101.manifestation.extent.should eq 'xv, 213 pages'
        item_10101.manifestation.dimensions.should eq '20cm'
        expect(item_10101.memo).to eq '個別資料メモ1'
        expect(item_10101.manifestation.memo).to eq '書誌メモ1'
        expect(item_10101.manifestation.required_role.name).to eq 'Guest'
        expect(item_10101.required_role.name).to eq 'Guest'

        item_10102 = Item.find_by(item_identifier: '10102')
        item_10102.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        item_10102.manifestation.language.name.should eq 'Japanese'
        item_10102.manifestation.height.should eq 257
        item_10102.manifestation.width.should eq 182
        item_10102.manifestation.depth.should eq 12
        item_10102.manifestation.start_page.should eq 1
        item_10102.manifestation.end_page.should eq 200
        item_10102.manifestation.series_statements.first.creator_string.should eq 'シリーズの著者'
        item_10102.manifestation.series_statements.first.volume_number_string.should eq 'シリーズ1号'
        expect(item_10102.manifestation.required_role.name).to eq 'Librarian'
        expect(item_10102.required_role.name).to eq 'Guest'

        Manifestation.find_by(manifestation_identifier: '103').original_title.should eq 'ダブル"クォート"を含む資料'
        item = Item.find_by(item_identifier: '11111')
        item.shelf.name.should eq Shelf.find(3).name
        item.manifestation.price.should eq 1000
        item.price.should eq 0
        item.manifestation.publishers.size.should eq 2

        item_10103 = Item.find_by(item_identifier: '10103')
        item_10103.budget_type.should be_nil
        item_10103.bookstore.name.should eq 'Example store'
        # 同じTSVファイル内では上書きされない
        expect(item_10103.manifestation.required_role.name).to eq 'Administrator'
        expect(item_10103.required_role.name).to eq 'Guest'

        item_10104 = Item.find_by(item_identifier: '10104')
        item_10104.manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        item_10104.budget_type.name.should eq 'Public fund'
        item_10104.bookstore.should be_nil
        item_10104.call_number.should eq '007|A'
        item_10104.manifestation.carrier_type.name.should eq 'online_resource'
        item_10104.manifestation.manifestation_content_type.name.should eq 'still_image'
        item_10104.manifestation.frequency.name.should eq 'unknown'
        item_10104.manifestation.volume_number_string.should eq '第3巻'
        item_10104.manifestation.volume_number.should eq 3
        item_10104.manifestation.issue_number_string.should eq '第10号'
        item_10104.manifestation.issue_number.should eq 10
        item_10104.manifestation.edition_string.should eq '初版'
        item_10104.manifestation.edition.should eq 1
        item_10104.manifestation.serial_number.should eq 120
        expect(item_10104.manifestation.doi_record.body).to eq 'example/2014.08.18'
        item_10104.manifestation.height.should be_nil
        item_10104.manifestation.width.should be_nil
        item_10104.manifestation.depth.should be_nil
        item_10104.manifestation.subjects.order(:id).map{|s| {s.subject_heading_type.name => s.term}}.should eq [{"ndlsh" => "コンピュータ"}, {"ndlsh" => "図書館"}]
        item_10104.manifestation.classifications.order(:id).map{|c| {c.classification_type.name => c.category}}.should eq [{"ndc9" => "007"}, {"ddc" => "003"}, {"ddc" => "004"}]
        expect(item_10104.manifestation.required_role.name).to eq 'Guest'
        expect(item_10104.required_role.name).to eq 'Guest'

        manifestation_104 = Manifestation.find_by(manifestation_identifier: '104')
        expect(manifestation_104.isbn_records.pluck(:body)).to eq ['9784797327038']
        expect(manifestation_104.original_title).to eq 'test10'
        manifestation_104.creators.pluck(:full_name).should eq ['test3']
        manifestation_104.publishers.pluck(:full_name).should eq ['test4']
        manifestation_105 = Manifestation.find_by(manifestation_identifier: '105')
        manifestation_105.serial.should be_truthy

        ResourceImportResult.where(manifestation_id: manifestation_101.id).order(:id).last.error_message.should eq "line 22: #{I18n.t('import.manifestation_found')}"
        ResourceImportResult.where(item_id: item_10101.id).order(:id).last.error_message.should eq "line 9: #{I18n.t('import.item_found')}"

        Item.find_by(item_identifier: '11113').manifestation.original_title.should eq 'test10'
        Item.find_by(item_identifier: '11114').manifestation.id.should eq 1

        item_10102 = Item.find_by(item_identifier: '10102')
        expect(item_10102.manifestation.manifestation_custom_values.pluck(:value)).to eq ['カスタム項目テスト1', 'カスタム項目テスト2']
        expect(item_10102.item_custom_values.pluck(:value)).to eq []
        item_10103 = Item.find_by(item_identifier: '10103')
        expect(item_10103.manifestation.manifestation_custom_values.pluck(:value)).to eq ["カスタム項目テスト1", "カスタム項目テスト2"]
        expect(item_10103.item_custom_values.pluck(:value)).to eq ['カスタム項目テスト3', 'カスタム項目テスト4']

        Manifestation.search{ keywords "10101" }.total.should > 0
        Manifestation.search{ keywords "10101", fields: [:item_identifier] }.total.should > 0
        Manifestation.search{ keywords "item_identifier_sm:10101" }.total.should > 0

        Message.count.should eq old_message_count + 1
        Message.order(:created_at).last.subject.should eq "Resource import completed: #{@file.id}"

        @file.executed_at.should be_truthy

        @file.reload
        @file.error_message.should eq "The following column(s) were ignored: invalid"
      end

      it "should import multiple ISBNs", vcr: true do
        file = ResourceImportFile.create(user: users(:admin))
        file.attachment.attach(io: StringIO.new("original_title\tisbn\noriginal_title_multiple_isbns\t978-4840239219//978-4043898039\n"), filename: 'test.txt')
        result = file.import_start
        expect(result[:manifestation_imported]).to eq 1
        resource_import_result = file.resource_import_results.last
        expect(resource_import_result.manifestation).not_to be_blank
        manifestation = resource_import_result.manifestation
        expect(manifestation.isbn_records.pluck(:body)).to include("9784840239219")
        expect(manifestation.isbn_records.pluck(:body)).to include("9784043898039")
      end

      it "should import multiple rows in a cell" do
        file = ResourceImportFile.create(
          attachment: fixture_file_upload("resource_import_file_sample5.tsv"),
          default_shelf_id: 3,
          user: users(:admin),
          edit_mode: 'create'
        )
        file.import_start

        manifestation = Manifestation.find_by(manifestation_identifier: 10201)
        expect(manifestation.original_title).to eq "改行を含む\nタイトル"
        expect(manifestation.abstract).to eq "改行を含む\n目次の\n情報"
        expect(manifestation.note).to eq "改行を\n含む\n注記の\n情報"
        expect(manifestation.description).to eq "改行を\n含む\n説明の情報"
      end
    end

    describe "ISBN import" do
      context "with record not found" do
        it "should record an error message", vcr: true do
          file = ResourceImportFile.create(user: users(:admin))
          file.attachment.attach(io: StringIO.new("isbn\n9780007264551"), filename: 'test.txt')
          result = file.import_start
          expect(result[:failed]).to eq 1
          resource_import_result = file.resource_import_results.last
          expect(resource_import_result.error_message).not_to be_empty
        end
      end

      context "with ISBN invalid" do
        it "should record an error message", vcr: true do
          file = ResourceImportFile.create(user: users(:admin))
          file.attachment.attach(io: StringIO.new("isbn\n978000726455x"), filename: 'test.txt')
          result = file.import_start
          expect(result[:failed]).to eq 1
          resource_import_result = file.resource_import_results.last
          expect(resource_import_result.error_message).not_to be_empty
        end
      end
    end

    describe "NCID import" do
      it "should import ncid value" do
        file = ResourceImportFile.create(user: users(:admin))
        file.attachment.attach(io: StringIO.new("original_title\tncid\noriginal_title_ncid\tBA67656964\n"), filename: 'test.txt')
        result = file.import_start
        expect(result[:manifestation_imported]).to eq 1
        resource_import_result = file.resource_import_results.last
        expect(resource_import_result.error_message).to be_blank
        expect(resource_import_result.manifestation).not_to be_blank
        manifestation = resource_import_result.manifestation
        expect(manifestation.ncid_record.body).to eq "BA67656964"
      end
    end

    describe "NDLBibID" do
      it "should import NDLBibID", vcr: true do
        file = ResourceImportFile.create(user: users(:admin))
        file.attachment.attach(io: StringIO.new("ndl_bib_id\nR100000002-I000000471440\n"), filename: 'test.txt')
        result = file.import_start
        expect(result[:manifestation_imported]).to eq 1
        resource_import_result = file.resource_import_results.last
        manifestation = resource_import_result.manifestation
        expect(manifestation.manifestation_identifier).to eq "https://ndlsearch.ndl.go.jp/books/R100000002-I000000471440"
      end
    end

    describe "when it is written in shift_jis" do
      before(:each) do
        @file = ResourceImportFile.create!(
          attachment: fixture_file_upload("resource_import_file_sample2.tsv"),
          user: users(:admin)
        )
      end

      it "should be imported", vcr: true do
        old_manifestations_count = Manifestation.count
        old_items_count = Item.count
        old_agents_count = Agent.count
        old_import_results_count = ResourceImportResult.count
        @file.import_start.should eq({manifestation_imported: 10, item_imported: 10, manifestation_found: 6, item_found: 3, failed: 7})
        manifestation = Item.find_by(item_identifier: '11111').manifestation
        manifestation.publishers.first.full_name.should eq 'test4'
        manifestation.publishers.first.full_name_transcription.should eq 'てすと4'
        manifestation.publishers.second.full_name_transcription.should eq 'てすと5'
        Manifestation.count.should eq old_manifestations_count + 10
        Item.count.should eq old_items_count + 10
        Agent.count.should eq old_agents_count + 9
        ResourceImportResult.count.should eq old_import_results_count + 23
        Item.find_by(item_identifier: '10101').manifestation.creators.size.should eq 2
        Item.find_by(item_identifier: '10101').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Item.find_by(item_identifier: '10102').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Item.find_by(item_identifier: '10104').manifestation.date_of_publication.should eq Time.zone.parse('2001-01-01')
        Manifestation.find_by(manifestation_identifier: '103').original_title.should eq 'ダブル"クォート"を含む資料'
        item = Item.find_by(item_identifier: '11111')
        item.shelf.name.should eq Shelf.find_by(name: 'web').name
        item.manifestation.price.should eq 1000
        item.price.should eq 0
        item.manifestation.publishers.size.should eq 2

        @file.executed_at.should be_truthy
      end
    end

    describe "when it has only isbn" do
      before(:each) do
        @file = ResourceImportFile.create!(
          attachment: fixture_file_upload("isbn_sample.txt"),
          user: users(:admin)
        )
      end

      it "should be imported", vcr: true do
        old_manifestations_count = Manifestation.count
        old_agents_count = Agent.count
        @file.import_start
        Manifestation.count.should eq old_manifestations_count + 1
        Agent.count.should eq old_agents_count + 5
        Manifestation.order(:id).last.publication_place.should eq '東京'
      end
    end

    describe "when it has only ncid" do
      before(:each) do
        @file = ResourceImportFile.create!(
          attachment: fixture_file_upload("ncid_sample.txt"),
          user: users(:admin)
        )
      end

      it "should be imported", vcr: true do
        old_manifestations_count = Manifestation.count
        old_agents_count = Agent.count
        @file.import_start
        Manifestation.count.should eq old_manifestations_count + 2
        Agent.count.should eq old_agents_count + 16
      end
    end

    describe "when it has only jpno" do
      before(:each) do
        @file = ResourceImportFile.create!(
          attachment: fixture_file_upload("jpno_sample.txt"),
          user: users(:admin)
        )
      end

      it "should be imported", vcr: true do
        old_manifestations_count = Manifestation.count
        old_agents_count = Agent.count
        @file.import_start
        Manifestation.count.should eq old_manifestations_count + 2
        Agent.count.should eq old_agents_count + 11
      end
    end

    describe "when it contains item related fields" do
      it "should create an item as well" do
        import_file = <<-EOF
original_title	call_number	item_note
resource_import_file_test1	007.6	note for the item.
        EOF
        file = ResourceImportFile.create(
          user: users(:admin)
        )
        file.attachment.attach(io: StringIO.new(import_file), filename: 'test.txt')
        old_manifestations_count = Manifestation.count
        old_items_count = Item.count
        result = file.import_start
        expect(Manifestation.count).to eq old_manifestations_count + 1
        expect(Item.count).to eq old_items_count + 1
        expect(file.resource_import_results.last.item).to be_valid
        expect(file.resource_import_results.last.item.call_number).to eq "007.6"
        expect(file.resource_import_results.last.item.note).to eq "note for the item."
      end
    end

    describe "when it contains edition fields" do
      it "should be imported" do
        import_file = <<-EOF
original_title	edition	edition_string
resource_import_file_test_edition	2	Revised Ed.
        EOF
        file = ResourceImportFile.create(
          user: users(:admin)
        )
        file.attachment.attach(io: StringIO.new(import_file), filename: 'test.txt')
        old_manifestations_count = Manifestation.count
        result = file.import_start
        expect(Manifestation.count).to eq old_manifestations_count + 1
        manifestation = Manifestation.all.find{|m| m.original_title == "resource_import_file_test_edition" }
        expect(manifestation.edition).to eq 2
        expect(manifestation.edition_string).to eq "Revised Ed."
      end
    end
    describe "when it contains transcription fields" do
      it "should be imported" do
        import_file = <<-EOF
original_title	title_transcription
resource_import_file_test_transcription	transcription
        EOF
        file = ResourceImportFile.create(
          user: users(:admin)
        )
        file.attachment.attach(io: StringIO.new(import_file), filename: 'test.txt')
        old_manifestations_count = Manifestation.count
        result = file.import_start
        expect(Manifestation.count).to eq old_manifestations_count + 1
        manifestation = Manifestation.all.find{|m| m.original_title == "resource_import_file_test_transcription" }
        expect(manifestation.title_transcription).to eq "transcription"
      end
    end

    describe "when it contains escaped fields" do
      it "should be imported as escaped" do
        import_file = <<-EOF
original_title	description	note	call_number	item_note
resource_import_file_test_description	test\\ntest	test\\ntest	test_description	test\\ntest
        EOF
        file = ResourceImportFile.create(
          user: users(:admin)
        )
        file.attachment.attach(io: StringIO.new(import_file), filename: 'test.txt')
        old_manifestations_count = Manifestation.count
        result = file.import_start
        expect(Manifestation.count).to eq old_manifestations_count + 1
        manifestation = Manifestation.all.find{|m| m.original_title == "resource_import_file_test_description" }
        expect(manifestation.description).to eq "test\ntest"
        expect(manifestation.note).to eq "test\ntest"
        expect(manifestation.items.first.note).to eq "test\ntest"
      end
    end

    describe "when it contains custom properties" do
      xit "should be imported" do
      end
    end
  end

  describe "when its mode is 'update'" do
    before(:each) do
      @file = ResourceImportFile.create!(
        attachment: fixture_file_upload("item_update_file.tsv"),
        user: users(:admin),
        edit_mode: 'update'
      )
    end

    it "should update items", vcr: true do
      @file.modify
      expect(@file.resource_import_results.first).to be_truthy
      expect(@file.resource_import_results.first.body).to match /item_identifier/
      item_00001 = Item.find_by(item_identifier: '00001')
      item_00001.manifestation.creators.order('agents.id').pluck(:full_name).should eq ['たなべ', 'こうすけ']
      item_00001.binding_item_identifier.should eq '900001'
      item_00001.binding_call_number.should eq '336|A'
      item_00001.binded_at.should eq Time.zone.parse('2014-08-16')
      item_00001.manifestation.subjects.order(:id).map{|subject| {subject.subject_heading_type.name => subject.term}}.should eq [{"ndlsh" => "test1"}, {"ndlsh" => "test2"}]
      expect(item_00001.manifestation.isbn_records.pluck(:body)).to eq ["4798002062"]
      expect(item_00001.manifestation.required_role.name).to eq 'Librarian'
      expect(item_00001.required_role.name).to eq 'Guest'

      item_00002 = Item.find_by(item_identifier: '00002')
      expect(item_00002.manifestation.publishers.pluck(:full_name)).to eq ['test2']
      expect(item_00002.manifestation.required_role.name).to eq 'Guest'
      expect(item_00002.required_role.name).to eq 'Guest'

      item_00003 = Item.find_by(item_identifier: '00003')
      item_00003.acquired_at.should eq Time.zone.parse('2012-01-01')
      item_00003.include_supplements.should be_truthy
      expect(item_00003.manifestation.required_role.name).to eq 'User'
      expect(item_00003.required_role.name).to eq 'Administrator'

      Item.find_by(item_identifier: '00004').include_supplements.should be_falsy

      item_00025 = Item.find_by(item_identifier: '00025')
      expect(item_00025.manifestation.original_title).to eq "テスト4"
      expect(item_00025.manifestation.subjects.pluck(:term)).to eq ['test2', 'test3']
      expect(item_00025.call_number).to eq "547|ヤ"
    end

    it "should update custom values", vcr: true do
      @file.import_start
      item_00001 = Item.find_by(item_identifier: '00001')
      expect(item_00001.manifestation.manifestation_custom_values.pluck(:manifestation_custom_property_id, :value)).to eq [[2, "カスタム項目5"]]
      expect(item_00001.item_custom_values.order(:item_custom_property_id).first.value).to eq "カスタム項目6"
    end

    # it "should update series_statement", vcr: true do
    #  manifestation = Manifestation.find(10)
    #  file = ResourceImportFile.create attachment: fixture_file_upload("update_series_statement.tsv"), edit_mode: 'update'
    #  file.modify
    #  manifestation.reload
    #  manifestation.series_statements.should eq [SeriesStatement.find(2)]
    # end

    describe "NCID import" do
      it "should import ncid value" do
        file = ResourceImportFile.create(user: users(:admin), edit_mode: 'update')
        file.attachment.attach(io: StringIO.new("manifestation_id\tncid\n1\tBA67656964\n"), filename: 'test.txt')
        result = file.import_start
        # expect(result[:manifestation_found]).to eq 1
        expect(file.error_message).to be_nil
        resource_import_result = file.resource_import_results.last
        expect(resource_import_result.error_message).to be_blank
        expect(resource_import_result.manifestation).not_to be_blank
        manifestation = resource_import_result.manifestation
        expect(manifestation.ncid_record.body).to eq "BA67656964"
      end
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove items", vcr: true do
      old_count = Item.count
      file = ResourceImportFile.create!(
        user: users(:admin),
        edit_mode: 'destroy'
      )
      file.attachment.attach(io: File.open("spec/fixtures/files/item_delete_file.tsv"), filename: 'test.txt')
      file.remove
      Item.count.should eq old_count - 1
    end
  end

  it "should import in background", vcr: true do
    file = ResourceImportFile.create!(
      user: users(:admin)
    )
    file.attachment.attach(io: File.open("spec/fixtures/files/resource_import_file_sample1.tsv"), filename: 'test.txt')
    ResourceImportFileJob.perform_later(file).should be_truthy
  end
end

# == Schema Information
#
# Table name: resource_import_files
#
#  id                          :bigint           not null, primary key
#  parent_id                   :bigint
#  user_id                     :bigint
#  note                        :text
#  executed_at                 :datetime
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  edit_mode                   :string
#  resource_import_fingerprint :string
#  error_message               :text
#  user_encoding               :string
#  default_shelf_id            :bigint
#
