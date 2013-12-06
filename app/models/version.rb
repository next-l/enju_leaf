require 'paper_trail'

class Version < ActiveRecord::Base
  class << self
    def export_for_incremental_synchronization(version_id)
      raise ArgumentError, 'no version id given' if version_id.blank?

      versions = where(arel_table[:id].gt(version_id)).
        order(:id).
        readonly.
        all

      versions.each do |version|
        filterout_personal_attributes_from_version!(version)
      end

      latest = versions.inject({}) do |hash, version|
        hash[version.item_type] ||= []
        hash[version.item_type] << version.item_id
        hash
      end.inject({}) do |hash, (item_type, item_ids)|
        hash[item_type] ||= {}
        model_class = item_type.constantize
        model_class.where(:id => item_ids.uniq).each do |record|
          hash[item_type][record.id] =
            filterout_personal_attributes(
              item_type, record.attributes)
        end
        hash
      end

      {versions: versions, latest: latest}
    end

    def import_for_incremental_synchronization!(dump)
      logfile = "#{Rails.root}/log/sync_import.log"
      last_processed = current_proccessing = nil
      item_attributes = nil

      # レコード毎の履歴
      table = dump[:versions].inject({}) do |hash, version|
        hash[version.item_type] ||= {}
        hash[version.item_type][version.item_id] ||= []
        hash[version.item_type][version.item_id] << version
        hash
      end

      dump[:versions].each do |version|
        current_proccessing = version
        item_versions = table[version.item_type][version.item_id]

        # PaperTrailのVersionレコードには
        # イベント発生前の状態が記録されている。
        # したがって、あるイベントによって変化した後の
        # レコードの状態は、同じレコードに関する
        # その次のVersionレコードに記録される。
        #
        # ここでitem_versionsの先頭はversionと同一で、
        # イベント発生前のレコードの状態を保持している。
        # レコード復元のためには「その次」の履歴が必要となる。
        item_versions.shift
        next_version = item_versions.first

        model_class = version.item_type.constantize
        event = version.event
        begin
          case event
          when 'destroy'
            record = model_class.find(version.item_id) rescue nil
            record.destroy if record 
            item_attributes = nil
            last_processed = current_proccessing

          when 'create', 'update'
            if next_version
              item_attributes = next_version.reify.attributes
            else
              # PaperTrailによる「その次」の記録がない場合、
              # そのレコードの「最新」の状態を別に取得する。
              item_attributes = dump[:latest][version.item_type][version.item_id]
            end

            if event == 'update'
              # 復元対象となるレコードの
              # 現能の状態を取得してそれを更新する。
              current = model_class.find(item_attributes['id']) rescue nil
              if current
                copy_attributes(current, item_attributes)
                current.save! 
                last_processed = current_proccessing
                next
              end
            end

            # レコードがないので作成する
            transaction do
              created = model_class.create! do |r|
                copy_attributes(r, item_attributes)
                incremental_synchronization_hook(:before_create, r)
              end
              incremental_synchronization_hook(:after_create, created)
            end

            last_processed = current_proccessing
          end # case event

          Sunspot.commit
        rescue Exception => e
          time = Time.now
          str = "#{time}: version.id => #{version.id}, version.item_type => #{version.item_type}, version.item_id => #{version.item_id}, version.event => #{version.event}"
          File.open logfile, 'a' do |f|
            f.puts str
            f.puts e
            f.puts
          end 
        end
      end # dump[:versions].each

      {
        success: true,
        exception: nil,
        last_event_time: last_processed.try(:created_at),
        last_event_id: last_processed.try(:id),
        failed_event_time: nil,
        failed_event_id: nil,
      }
    rescue => ex
      failed_event = {
        event_type: current_proccessing.event,
        item_type: current_proccessing.item_type,
        item_id: current_proccessing.item_id,
        item_attributes: item_attributes,
      }
      logger.warn "import failed on \"#{failed_event[:event_type]} #{failed_event[:item_type]}\##{failed_event[:item_id]}\" (Version\##{current_proccessing.id}): #{ex.try(:message)} (#{ex.class})"
      {
        success: false,
        exception: {
          class: ex.class,
          message: ex.try(:message),
          backtrace: ex.try(:backtrace),
        },
        last_event_time: last_processed.try(:created_at),
        last_event_id: last_processed.try(:id),
        failed_event_time: current_proccessing.created_at,
        failed_event_id: current_proccessing.id,
        failed_event: failed_event,
      }
    ensure
      Sunspot.commit
    end

    private

      NON_PERSONAL_ATTRIBUTES = %w(
        id
        created_at updated_at deleted_at
        language_id country_id patron_type_id
        required_role_id required_score
        patron_identifier exclude_state
      )

      PERSONAL_ATTRIBUTE_MASK = {
        'full_name' => proc do |item_attributes|
          "(Patron\##{item_attributes['id']})"
        end,
      }

      def filterout_personal_attributes(item_type, item_attributes)
        item_attributes.dup.tap do |hash|
          hash.each_pair do |name, value|
            # user_idがnilでないPatronレコードは
            # 一部を除いた属性を空にする
            if item_type == 'Patron' &&
                item_attributes['user_id'].present? &&
                !NON_PERSONAL_ATTRIBUTES.include?(name)
              if PERSONAL_ATTRIBUTE_MASK.include?(name)
                value = PERSONAL_ATTRIBUTE_MASK[name].call(item_attributes)
              else
                value = nil
              end
            end
            hash[name] = value
          end
        end
      end

      def filterout_personal_attributes_from_version!(version)
        return unless version.object

        # NOTE
        # versions.objectの内容を書き換えて個人情報を除去する。
        # 書き換えに際してはPaperTrailの仕様に合わせること。
        #
        # PaperTrail 2.6.4ではattributesがYAMLで格納されている。
        # YAMLへの変換はaudit対象クラスに追加される
        # object_to_stringメソッドを通じてto_yamlで行われる。
        # YAMLからのロードはVersionのreifyメソッドを通じて
        # YAML.loadで行われる。
        version.object =
          filterout_personal_attributes(
            version.item_type, YAML.load(version.object)).
          to_yaml
      end

      def copy_attributes(record, attributes)
        record.class.column_names.each do |c|
          next if c == "lock_version"
          record.__send__(:"#{c}=", attributes[c])
        end
      end

      def incremental_synchronization_hook(hook, record)
        case record
        when Library
          if hook == :before_create
            class << record
              extend IncrementalSynchronization
              hide_methods_for_incremental_synchronization(:create_shelf, :set_patron)
            end
          elsif hook == :after_create
            class << record
              revert_methods_for_incremental_synchronization(:create_shelf, :set_patron)
            end
          end
        end
      end

      module IncrementalSynchronization
        def hide_methods_for_incremental_synchronization(*methods)
          methods.each do |method|
            alias_method(:"incremental_synchronization_hook_#{method}", method)
            define_method(method) { }
          end
        end

        def revert_methods_for_incremental_synchronization(*methods)
          methods.each do |method|
            alias_method(method, :"incremental_synchronization_hook_#{method}")
            undef_method(:"incremental_synchronization_hook_#{method}")
          end
        end
      end
  end # class << self
end
