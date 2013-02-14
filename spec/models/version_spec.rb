# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Version do
  fixtures :all

  # NOTE: 差分同期機能について
  #
  # 同期が必要なモデルと、それぞれの必須関連属性
  #
  # * Item
  #    * circulation_status
  #    * checkout_type
  #    * shelf
  #    * required_role(role)
  #    * retention_period
  #
  # * Manifestation
  #    * carrier_type
  #    * language
  #    * manifestation_type
  #    * country_of_pulication
  #    * required_role(role)
  #    * extent
  #
  # * Shelf
  #    * library
  #
  # * Patron
  #    * language
  #    * patron_type
  #    * country
  #    * required_role(role)
  #
  # * Subject
  #    * subject_type
  #    * required_role(role)
  #
  # * SeriesStatement
  #
  # 上の各モデルと関連付けられるモデルと、それぞれの必須関連属性
  #
  # * Create
  #    * work(manifestation)
  #    * patron
  #
  # * Produce
  #    * manifestation
  #    * patron
  #
  # * Realize
  #    * expression(manifestation)
  #    * patron
  #
  # * Exemplify
  #    * manifestation
  #    * item
  #
  # * WorkHasSubject
  #    * subject
  #    * work(manifestation)
  #
  # * SeriesHasManifestation
  #    * series_statement
  #    * manifestation
  #
  # * Library
  #    * library_group
  #    * patron
  #
  # * Role
  #
  # * CarrierType
  #
  # * Language
  #
  # * ManifestationType
  #
  # * Country
  #
  # * CirculationStatus
  #
  # * CheckoutType
  #
  # * Extent
  #
  # * PatronType
  #
  # * LibraryGroup

  # レコード比較の一部として属性を比較する際に
  # 同値をとれれない属性について無視または
  # 一定程度の整調をする
  def round(attributes)
    attributes.dup.tap do |h|
      h.delete('lock_version')
      h.each_key do |k|
        h[k] = h[k].strftime('%Y-%m-%d %H:%M:%S') if h[k].is_a?(Time) # 秒まで同じことを検査
      end
    end
  end

  def latest_version_id
    Version.last.try(:id) || 0
  end

  describe '.export_for_incremental_synchronizationは' do
    it '指定した日時以降の変動と、最新の状態をエクスポートできること' do
      vid = latest_version_id
      sleep 1

      # create
      role = Role.create!(
        name: 'test_role',
        display_name: 'test1')

      dump = Version.export_for_incremental_synchronization(vid)
      dump[:versions].should have(1).item
      dump[:versions].map(&:event).should == %w(create)
      dump[:latest]['Role'].should be_a(Hash)
      dump[:latest]['Role'][role.id].should be_a(Hash)
      round(dump[:latest]['Role'][role.id]).should == round(role.attributes)

      # update
      role.display_name = 'test2'
      role.save!

      dump = Version.export_for_incremental_synchronization(vid)
      dump[:versions].should have(2).item
      dump[:versions].map(&:event).should == %w(create update)
      dump[:latest]['Role'].should be_a(Hash)
      dump[:latest]['Role'][role.id].should be_a(Hash)
      round(dump[:latest]['Role'][role.id]).should == round(role.attributes)

      # destroy
      role.destroy

      dump = Version.export_for_incremental_synchronization(vid)
      dump[:versions].should have(3).item
      dump[:versions].map(&:event).should == %w(create update destroy)
      dump[:latest]['Role'].should be_a(Hash)
      dump[:latest]['Role'][role.id].should be_nil
    end

    it 'Userに関連付けられたPatronの個人情報はエクスポートしないこと' do
      keep_attributes = %w(
        id
        created_at updated_at deleted_at
        language_id country_id patron_type_id
        required_role_id required_score
        patron_identifier exclude_state
      )
      vid = latest_version_id

      attributes = Patron.column_names.
        reject {|name| /\Aid\z|_(id|at)\z|\Adate_of_|\Alock_version\z/ =~ name }.
        inject({}) {|hash, name| hash[name] = name; hash }.
        merge!({
          'language' => languages(:language_00001),
          'patron_type' => patron_types(:patron_type_00001),
          'country' => countries(:country_00001),
          'birth_date' => Date.new(1900, 1, 1),
          'death_date' => Date.new(1950, 1, 1),
          'email' => 'foo@example.jp',
        })

      patron1 = Patron.create! do |patron|
        attributes.each_pair do |k, v|
          patron.__send__("#{k}=", v)
          patron.full_name = 'patron_a'
        end
      end
      patron1.reload
      attributes1 = patron1.attributes

      patron2 = Patron.create! do |patron|
        attributes.each_pair do |k, v|
          patron.__send__("#{k}=", v)
          patron.full_name = 'patron_b'
          patron.user = users(:user5)
        end
      end
      patron2.reload
      attributes2 = patron2.attributes

      dump1 = Version.export_for_incremental_synchronization(vid)

      patron1.destroy
      patron2.destroy
      dump2 = Version.export_for_incremental_synchronization(vid)

      [dump1, dump2].inject([]) do |all, dump|
        dump[:versions].inject(all) {|ary, ver| ary << ver }
        dump[:latest].inject(all) do |ary, (cls, hsh)|
          hsh.inject(ary) {|a, (id, attrs)| a << [cls, id, attrs] }
        end
      end.each do |object|
        if object.is_a?(Version)
          if object.event == 'create'
            object.object.should be_nil
            next
          end
          item_type = object.item_type
          item_id = object.item_id
          item_attributes = YAML.load(object.object)
        else
          item_type, item_id, item_attributes = *object
        end

        item_attributes.each_pair do |name, value|
          if item_id == patron1.id
            # 個人情報は保持される
            if name == 'full_name'
              value.should match(/\Apatron_[aA]\z/),
                "attribute #{name.inspect} should be /patron_[aA]/, but #{value.inspect}"
            else
              value.should be_eql(attributes1[name]),
                "attribute #{name.inspect} should be #{attributes1[name].inspect}, but #{value.inspect}"
            end

          else
            # 個人情報は保持されない
            if name == 'full_name'
              expect = "(#{item_type}\##{item_id})"
              value.should be_eql(expect),
                "attribute #{name.inspect} should be #{expect.inspect}, but #{value.inspect}"
            elsif keep_attributes.include?(name)
              value.should be_eql(attributes2[name])
                "attribute #{name.inspect} should be #{attributes2[name].inspect}, but #{value.inspect}"
            else
              value.should be_nil,
                "attribute #{name.inspect} should be nil, but #{value.inspect}"
            end
          end
        end
      end
    end
  end

  describe '.import_for_incremental_synchronization!は' do
    def create_record(attributes = attributes)
      model_class.create! do |record|
        attributes.each do |name, value|
          record.__send__(:"#{name}=", value)
        end
      end
    end

    def update_record(record, attributes = {})
      attributes.each_pair do |name, value|
        record.__send__(:"#{name}=", value)
      end
      record.save!
      record
    end

    def destroy_record(record)
      record.destroy
    end

    def make_change(history, name)
      vid = latest_version_id

      sleep 1
      ret = yield
      sleep 1

      history ||= []
      history << {
        name: name,
        vid: vid,
        class: ret.class,
        attributes: ret.attributes,
        dump: Version.export_for_incremental_synchronization(vid)
      }

      ret
    end

    def replay_changes(history, record)
      initial_vid = history.first[:vid]
      dump_all = Version.export_for_incremental_synchronization(initial_vid)

      # 一工程ごとに戻していく
      history.each do |state|
        dump = state[:dump]
        case state[:name]
        when /^create/
          delta = 1
          attributes = state[:attributes]
        when /^update/
          delta = 0
          attributes = state[:attributes]
        when /^destroy/
          delta = -1
          attributes = nil
        end

        lambda {
          Version.import_for_incremental_synchronization!(dump)
        }.should change(model_class, :count).by(delta)

        if attributes
          reverted = model_class.find(record.id)
          reverted.should be_present
          reverted.should be_a(model_class)

          round(reverted.attributes).should == round(attributes)
        else
          lambda {
            model_class.find(record.id)
          }.should raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      # 全工程を一度に戻す
      lambda {
        Version.import_for_incremental_synchronization!(dump_all)
      }.should_not change(model_class, :count)
    end

    shared_examples_for '記録されていた状態に復元する' do
      it '復元できること' do
        history = []

        record = make_change(history, 'create') do
          create_proc.call
        end

        (1..3).each do |i|
          make_change(history, "update #{i}") do
            update_proc.call(record, i)
          end
        end if update_proc

        make_change(history, 'destroy') do
          destroy_proc.call(record)
        end

        replay_changes(history, record)
      end
    end

    let(:destroy_proc) do
      proc do |record|
        destroy_record(record)
      end
    end

    let(:create_proc) do
      proc do
        create_record(
          name: 'test_record',
          display_name: 'created')
      end
    end

    let(:update_proc) do
      proc do |record, seq|
        update_record(record, display_name: "updated#{seq}")
      end
    end

    describe 'Roleを' do
      let(:model_class) { Role }
      include_examples '記録されていた状態に復元する'
    end

    describe 'Languageを' do
      let(:model_class) { Language }
      let(:create_proc) do
        proc do
          create_record(
            name: 'test_record',
            display_name: 'created',
            iso_639_1: 'xz',
            iso_639_2: 'xyz',
            iso_639_3: 'xyz')
        end
      end
      include_examples '記録されていた状態に復元する'
    end

    describe 'ManifestationTypeを' do
      let(:model_class) { ManifestationType }
      include_examples '記録されていた状態に復元する'
    end

    describe 'Countryを' do
      let(:model_class) { Country }
      let(:create_proc) do
        proc do
          create_record(
            name: 'test_record',
            display_name: 'created',
            alpha_2: 'XZ',
            alpha_3: 'XYZ',
            numeric_3: '999')
        end
      end
      include_examples '記録されていた状態に復元する'
    end

    describe 'CirculationStatusを' do
      let(:model_class) { CirculationStatus }
      include_examples '記録されていた状態に復元する'
    end

    describe 'CheckoutTypeを' do
      let(:model_class) { CheckoutType }
      include_examples '記録されていた状態に復元する'
    end

    describe 'Extentを' do
      let(:model_class) { Extent }
      include_examples '記録されていた状態に復元する'
    end

    describe 'PatronTypeを' do
      let(:model_class) { PatronType }
      include_examples '記録されていた状態に復元する'
    end

    describe 'CarrierTypeを' do
      let(:model_class) { CarrierType }
      include_examples '記録されていた状態に復元する'
    end

    describe 'LibraryGroupを' do
      let(:model_class) { LibraryGroup }
      let(:create_proc) do
        proc do
          create_record(
            name: 'test_record',
            display_name: 'created',
            short_name: 'created',
            email: 'foo@example.jp',
            url: 'http://example.jp')
        end
      end
      include_examples '記録されていた状態に復元する'
    end

    describe 'Libraryを' do
      let(:model_class) { Library }

      let(:create_proc) do
        proc do
          create_record(
            name: 'testrecord',
            short_display_name: 'created')
        end
      end

      let(:update_proc) do
        proc do |record, i|
          patron = record.patron

          update_record(
            record, patron: patrons(:"patron_0010#{i}"))

          # Library.create時に自動的に作成された
          # Patronレコードをテストのために削除しておく
          patron.destroy if i == 1

          record
        end
      end

      let(:destroy_proc) do
        proc do |record|
          shelves = record.shelves

          destroy_record(record)

          # Library.create時に自動的に作成された
          # Shelfレコードをテストのために削除しておく
          record.shelves.each do |shelf|
            shelf.destroy
          end

          record
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'Itemを' do
      let(:model_class) { Item }

      let(:create_proc) do
        proc do
          create_record(
            circulation_status: circulation_statuses(:circulation_status_00009),
            checkout_type: checkout_types(:checkout_type_00001),
            retention_period: @retention_period,
            url: 'http://example.jp')
        end
      end

      let(:update_proc) do
        proc do |record, i|
          update_record(
            record,
            circulation_status: circulation_statuses(:"circulation_status_0000#{i}"),
            url: "http://example.jp/#{i}")
        end
      end

      before do
        @retention_period = FactoryGirl.create(:retention_period)
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'SeriesStatementを' do
      let(:model_class) { SeriesStatement }

      let(:create_proc) do
        proc do
          create_record(
            original_title: 'created')
        end
      end

      let(:update_proc) do
        proc do |record, i|
          update_record(
            record,
            original_title: "updated #{i}")
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'Manifestationを' do
      let(:model_class) { Manifestation }

      let(:create_proc) do
        proc do
          create_record(
            manifestation_type: @manifestation_type,
            carrier_type: carrier_types(:carrier_type_00001),
            original_title: 'test record')
        end
      end

      let(:update_proc) do
        proc do |record, i|
          update_record(
            record,
            carrier_type: carrier_types(:"carrier_type_0000#{i}"),
            original_title: "title #{i}")
        end
      end

      before do
        @manifestation_type = FactoryGirl.create(:manifestation_type)
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'Shelfを' do
      let(:model_class) { Shelf }

      let(:create_proc) do
        proc do
          create_record(
            name: 'testrecord',
            display_name: 'created',
            library: @library)
        end
      end

      before do
        @library = FactoryGirl.create(:library)
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'Patronを' do
      let(:model_class) { Patron }

      let(:create_proc) do
        proc do
          create_record(
            full_name: 'test record',
            language: languages(:language_00001),
            patron_type: patron_types(:patron_type_00001),
            country: countries(:country_00001))
        end
      end

      let(:update_proc) do
        proc do |record, i|
          update_record(
            record,
            country: countries(:"country_0010#{i}"),
            full_name: "updated#{i}")
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'Userに関連付けられたPatronを' do
      let(:model_class) { Patron }

      it '復元できること' do
        vid = latest_version_id
        patron = patron_id = dump = nil

        ActiveRecord::Base.transaction do
          patron = create_record(
            full_name: 'test record',
            language: languages(:language_00001),
            patron_type: patron_types(:patron_type_00001),
            country: countries(:country_00001),
            user: users(:user5))
          patron_id = patron.id

          dump = Version.export_for_incremental_synchronization(vid)
          raise ActiveRecord::Rollback
        end

        lambda {
          Version.import_for_incremental_synchronization!(dump)
        }.should change(model_class, :count).by(1)

        imported = model_class.find(patron_id)
        %w(language patron_type country user).each do |name|
          imported[name].should be_eql(patron[name])
        end
      end
    end

    describe 'Subjectを' do
      let(:model_class) { Subject }

      let(:create_proc) do
        proc do
          create_record(
            term: 'testrecord',
            subject_type_id: subject_types(:subject_type_00004).id)
        end
      end

      let(:update_proc) do
        proc do |record, i|
          update_record(
            record,
            subject_type_id: subject_types(:"subject_type_0000#{i}").id,
            term: "updated#{i}")
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    shared_examples_for 'Manifestation-Patron関連を復元する' do
      before do
        @manifestation_type = FactoryGirl.create(:manifestation_type)
        @manifestation = FactoryGirl.create(
          :manifestation,
          manifestation_type: @manifestation_type,
          carrier_type: carrier_types(:carrier_type_00001))
      end

      let(:create_proc) do
        proc do
          @patron = FactoryGirl.create(
            :patron,
            language: languages(:language_00001),
            patron_type: patron_types(:patron_type_00001),
            country: countries(:country_00001))

          @manifestation.__send__(relation1) << @patron
          @manifestation.__send__(relation2).where(:patron_id => @patron).first
        end
      end

      let(:update_proc) do
        nil
      end

      let(:destroy_proc) do
        proc do |record|
          @patron.destroy
          record
        end
      end
    end

    describe 'Createを' do
      let(:model_class) { Create }

      let(:relation1) { :creators }
      let(:relation2) { :creates }

      include_examples 'Manifestation-Patron関連を復元する'
      include_examples '記録されていた状態に復元する'
    end

    describe 'Produceを' do
      let(:model_class) { Produce }

      let(:relation1) { :publishers }
      let(:relation2) { :produces }

      include_examples 'Manifestation-Patron関連を復元する'
      include_examples '記録されていた状態に復元する'
    end

    describe 'Realizeを' do
      let(:model_class) { Realize }

      let(:relation1) { :contributors }
      let(:relation2) { :realizes }

      include_examples 'Manifestation-Patron関連を復元する'
      include_examples '記録されていた状態に復元する'
    end

    describe 'Exemplifyを' do
      let(:model_class) { Exemplify }

      before do
        @manifestation_type = FactoryGirl.create(:manifestation_type)
        @manifestation = FactoryGirl.create(
          :manifestation,
          manifestation_type: @manifestation_type,
          carrier_type: carrier_types(:carrier_type_00001))
        @retention_period = FactoryGirl.create(:retention_period)
      end

      let(:create_proc) do
        proc do
          @item = Item.create(
            circulation_status: circulation_statuses(:circulation_status_00009),
            checkout_type: checkout_types(:checkout_type_00001),
            retention_period: @retention_period)

          @manifestation.items << @item
          @manifestation.exemplifies.where(:item_id => @item).first
        end
      end

      let(:update_proc) do
        nil
      end

      let(:destroy_proc) do
        proc do |record|
          record = record.destroy
          @item.destroy
          record
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'WorkHasSubjectを' do
      let(:model_class) { WorkHasSubject }

      before do
        @manifestation_type = FactoryGirl.create(:manifestation_type)
        @manifestation = FactoryGirl.create(
          :manifestation,
          manifestation_type: @manifestation_type,
          carrier_type: carrier_types(:carrier_type_00001))
      end

      let(:create_proc) do
        proc do
          @subject = Subject.create(
            term: 'testrecord',
            subject_type_id: subject_types(:subject_type_00004).id)

          @manifestation.subjects << @subject
          @manifestation.work_has_subjects.where(:subject_id => @subject).first
        end
      end

      let(:update_proc) do
        nil
      end

      let(:destroy_proc) do
        proc do |record|
          subject = record.subject
          @manifestation.subjects.destroy(subject)
          subject.destroy
          record
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'SeriesHasManifestationを' do
      let(:model_class) { SeriesHasManifestation }

      before do
        @manifestation_type = FactoryGirl.create(:manifestation_type)
        @manifestation = FactoryGirl.create(
          :manifestation,
          manifestation_type: @manifestation_type,
          carrier_type: carrier_types(:carrier_type_00001))
      end

      let(:create_proc) do
        proc do
          @series_statement = SeriesStatement.create(
            original_title: 'test series')

          @manifestation.series_statement = @series_statement
          SeriesHasManifestation.
            where(series_statement_id: @series_statement,
                  manifestation_id: @manifestation).
            first
        end
      end

      let(:update_proc) do
        nil
      end

      let(:destroy_proc) do
        proc do |record|
          record.series_statement.destroy
          record.destroy
          record
        end
      end

      include_examples '記録されていた状態に復元する'
    end

    describe 'イベント処理で' do
      before do
        @time = []
        @vid = []

        @role = Role.create!(name: 'test', display_name: 'test')
        @role_id = @role.id

        ActiveRecord::Base.transaction do
          @time << Time.now
          @vid << latest_version_id
          sleep 1

          # イベント#0: 時刻=@time[0]...@time[1] id=@vid[1]
          @role.display_name = 'test2'
          @role.save!

          sleep 1
          @time << Time.now
          @vid << latest_version_id
          sleep 1

          # イベント#1: 時刻=@time[1]...@time[2] id=@vid[2]
          @role.display_name = 'test3'
          @role.save!

          sleep 1
          @time << Time.now
          @vid << latest_version_id
          sleep 1

          # イベント#2: 時刻=@time[2]...@time[1] id=@vid[3]
          @role.display_name = 'test4'
          @role.save!

          sleep 1
          @time << Time.now
          @vid << latest_version_id
          sync_export(@vid.first)

          raise ActiveRecord::Rollback
        end
      end

      def sync_export(vid)
        @dump = Version.export_for_incremental_synchronization(vid)
      end

      def sync_import!
        @status = Version.import_for_incremental_synchronization!(@dump)
      end

      def break_event!(idx)
        version = @dump[:versions][idx + 1] # idx番目のイベント処理で例外を発生させるためには、その次のVersionのobjectに手を入れる必要がある

        # PaperTrailの記録を直接いじる。
        # Paper Trail 2.6.4ではattributesを
        # to_yamlしたものを格納しており、
        # YAML.loadにより復元している。
        item_attributes = YAML.load(version.object)
        item_attributes['name'] = '' # roles.nameは空にできないため例外が発生する
        version.object = item_attributes.to_yaml
      end

      context 'すべて正常に実行できとき' do
        before do
          sync_import!
        end

        it '最後に処理したイベントの時刻とidを返すこと' do
          @status[:last_event_time].should be_present
          @status[:last_event_time].should satisfy {|t| (@time[-2]...@time[-1]).cover?(t) }
          @status[:last_event_id].should be_present
          @status[:last_event_id].should == @vid[-1]
        end

        it 'trueを返すこと' do
          @status[:success].should be_true
        end
      end

      context '処理するものがなかったとき' do
        before do
          sync_export(latest_version_id)
          sync_import!
        end

        it '処理したイベントの時刻とidを返さないこと' do
          @status[:last_event_time].should be_nil
          @status[:last_event_id].should be_nil
        end

        it 'trueを返すこと' do
          @status[:success].should be_true
        end
      end

      context '途中で例外が発生したとき' do
        before do
          break_event!(1)
          sync_import!
        end

        it '最後に正常に処理できたイベントの時刻とidを返すこと' do
          @status[:last_event_time].should be_present
          @status[:last_event_time].should satisfy {|t| (@time[0]...@time[1]).cover?(t) }
          @status[:last_event_id].should be_present
          @status[:last_event_id].should == @vid[1]
        end

        it '例外が発生したイベントの時刻とidを返すこと' do
          @status[:failed_event_time].should be_present
          @status[:failed_event_time].should satisfy {|t| (@time[1]...@time[2]).cover?(t) }
          @status[:failed_event_id].should be_present
          @status[:failed_event_id].should == @vid[2]
        end

        it '発生した例外を返すこと' do
          @status[:exception].should be_present
          @status[:exception][:class].should == ActiveRecord::RecordInvalid
        end

        it 'falseを返すこと' do
          @status[:success].should be_false
        end
      end

      context '例外発生によりまったく実行できなかったとき' do
        before do
          break_event!(0)
          sync_import!
        end

        it '処理したイベントの時刻とidを返さないこと' do
          @status[:last_event_time].should be_nil
          @status[:last_event_id].should be_nil
        end

        it '例外が発生したイベントの時刻とidを返すこと' do
          @status[:failed_event_time].should be_present
          @status[:failed_event_time].should satisfy {|t| (@time[0]...@time[1]).cover?(t) }
          @status[:failed_event_id].should be_present
          @status[:failed_event_id].should == @vid[1]
        end

        it '発生した例外を返すこと' do
          @status[:exception].should be_present
          @status[:exception][:class].should == ActiveRecord::RecordInvalid
        end

        it 'falseを返すこと' do
          @status[:success].should be_false
        end
      end
    end
  end
end
