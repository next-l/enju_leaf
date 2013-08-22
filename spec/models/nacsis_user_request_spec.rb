# encoding: utf-8
require 'spec_helper'

describe NacsisUserRequest do
  fixtures :countries, :languages, :patron_types, :roles, :user_groups, :library_groups, :libraries, :patrons

  describe '.createは' do
    it '新しいレコードを作成して返すこと' do
      expect(FactoryGirl.create(:nacsis_user_request)).to be_present
      expect(FactoryGirl.create(:nacsis_user_request)).to be_present
    end
  end

  describe '#valid?は' do
    subject { NacsisUserRequest }
    let(:user) { FactoryGirl.create(:user) }
    it 'user_idが空でないのを検査すること' do
      record = subject.new
      record.valid?
      expect(record.errors).to include(:user_id)

      record = subject.new
      record.user_id = user.id
      record.valid?
      expect(record.errors).not_to include(:user_id)
    end

    it 'userが空でないのを検査すること' do
      record = subject.new
      record.user_id = user.id
      record.valid?
      expect(record.errors).not_to include(:user)

      record = subject.new
      record.user_id = user.id + 100
      record.valid?
      expect(record.errors).to include(:user)
    end

    it 'userが正しいUserレコードを指しているのを検査すること' do
      record = subject.new
      record.user_id = user.id

      record.valid?
      expect(record.errors).not_to include(:user)

      record.user.stub(:valid? => false)
      record.valid?
      expect(record.errors).to include(:user)
    end

    it 'request_typeが空でないのを検査すること' do
      record = subject.new
      record.valid?
      expect(record.errors).to include(:request_type)

      record = subject.new
      record.request_type = 1
      record.valid?
      expect(record.errors).not_to include(:request_type)
    end

    it 'request_typeが1または2であるのを検査すること' do
      [1, 2].each do |i|
        record = subject.new
        record.request_type = i
        record.valid?
        expect(record.errors).not_to include(:request_type)
      end

      [-1, 0, 3].each do |i|
        record = subject.new
        record.request_type = i
        record.valid?
        expect(record.errors).to include(:request_type),
          "#{i.inspect} should be rejected"
      end
    end

    it 'stateが空でないのを検査すること' do
      record = subject.new
      record.state = nil # avoids default value of state
      record.valid?
      expect(record.errors).to include(:state)

      record = subject.new
      record.state = 0
      record.valid?
      expect(record.errors).not_to include(:state)
    end

    it 'stateが0〜8であるのを検査すること' do
      (0..8).each do |i|
        record = subject.new
        record.state = i
        record.valid?
        expect(record.errors).not_to include(:state)
      end

      [-1, 9].each do |i|
        record = subject.new
        record.state = i
        record.valid?
        expect(record.errors).to include(:state),
          "#{i.inspect} should be rejected"
      end
    end
  end

  describe 'seachableブロックは', :solr => true do
    def create_record(attrs = {})
      record = FactoryGirl.create(:nacsis_user_request, attrs)
      Sunspot.commit

      record
    end

    def search_record(attrs)
      NacsisUserRequest.search do
        attrs.each do |field, value|
          with(field, value)
        end
      end.results
    end

    def fulltext_search_record(text)
      NacsisUserRequest.search do
        fulltext(text)
      end.results
    end

    it 'stateをインデックスに登録すること' do
      state = 1
      record = create_record(:state => state)

      results = search_record(:state => state)
      expect(results).to include(record)

      results = search_record(:state => 2)
      expect(results).not_to include(record)
    end

    it 'request_typeをインデックスに登録すること' do
      request_type = 1
      record = create_record(:request_type => request_type)

      results = search_record(:request_type => request_type)
      expect(results).to include(record)

      results = search_record(:request_type => 2)
      expect(results).not_to include(record)
    end

    it 'ncidをインデックスに登録すること' do
      ncid = 'foobar'
      record = create_record(:ncid => ncid)

      results = search_record(:ncid => ncid)
      expect(results).to include(record)

      %w(baz foo ooba bar f o r).each do |word|
        results = search_record(:ncid => word)
        expect(results).not_to include(record)
      end
    end

    it 'created_atをインデックスに登録すること' do
      record = create_record

      range = record.created_at.beginning_of_day..record.created_at.end_of_day
      results = search_record(:created_at => range)
      expect(results).to include(record)

      yesterday = record.created_at.yesterday
      tomorrow = record.created_at.tomorrow
      [
        yesterday.beginning_of_day..yesterday.end_of_day,
        tomorrow.beginning_of_day..tomorrow.end_of_day,
      ].each do |range|
        results = search_record(:created_at => range)
        expect(results).not_to include(record),
          "the record is not created in #{range}"
      end
    end

    [:subject_heading, :author_heading].each do |field|
      it "#{field}をインデックスに登録すること" do
        str = '私の名前は中野です'
        record = create_record(field => str)

        results = fulltext_search_record(str)
        expect(results).to include(record)

        [
          '私の名前は', '中野です',
          '私*', '*前*', '*す',
          '名前 中野', '中野 名前',
          '中野てす',
        ].each do |word|
          results = fulltext_search_record(word)
          expect(results).to include(record),
            "#{word.inspect} should hit the record"
        end

        [
          '私は中野です',
          "以前の#{str}",
          '野中',
          '私', '前', 'す',
        ].each do |word|
          results = fulltext_search_record(word)
          expect(results).not_to include(record),
            "#{word.inspect} should not hit the record"
        end
      end
    end

    it 'user_idをインデックスに登録すること' do
      user = FactoryGirl.create(:user)
      record = create_record(:user => user)

      results = search_record(:user_id => user.id)
      expect(results).to include(record)

      other = FactoryGirl.create(:user)
      results = search_record(:user_id => other.id)
      expect(results).not_to include(record)
    end
  end
end
