require 'active_record/fixtures'
require 'tasks/profile'
require 'tasks/attachment'

namespace :enju_leaf do
  desc "create initial records for enju_leaf"
  task :setup => :environment do
    Dir.glob(Rails.root.to_s + '/db/fixtures/enju_leaf/*.yml').each do |file|
      ActiveRecord::FixtureSet.create_fixtures('db/fixtures/enju_leaf', File.basename(file, '.*'))
    end

    Rake::Task['enju_seed:setup'].invoke
    Rake::Task['enju_biblio:setup'].invoke
    Rake::Task['enju_library:setup'].invoke
    Rake::Task['enju_circulation:setup'].invoke
    Rake::Task['enju_subject:setup'].invoke

    puts 'initial fixture files loaded.'
  end

  desc "import users from a TSV file"
  task :user_import => :environment do
    UserImportFile.import
  end

  desc "upgrade enju_leaf"
  task :upgrade => :environment do
    Rake::Task['enju_library:upgrade'].invoke
    Rake::Task['enju_biblio:upgrade'].invoke
    Rake::Task['enju_event:upgrade'].invoke
    Rake::Task['enju_message:upgrade'].invoke
    Rake::Task['enju_circulation:upgrade'].invoke
    puts 'enju_leaf: The upgrade completed successfully.'
  end

  desc "reindex all models"
  task :reindex, [:batch_size, :models, :silence] => :environment do |_t, args|
    Rails::Engine.subclasses.each{|engine| engine.instance.eager_load!}
    Rake::Task['sunspot:reindex'].execute(args)
  end

  desc 'Export items'
  task :item => :environment do
    puts Manifestation.export(format: :txt)
  end

  desc 'Load default asset files'
  task :load_asset_files => :environment do
    library_group = LibraryGroup.order(created_at: :desc).first
    if library_group.header_logo.blank?
      library_group.header_logo = File.open(Rails.root.join("app/assets/images/enju_leaf/enju-logo-yoko-without-white.png"))
      library_group.save!
    end

    if File.stat(Rails.root.join('public/favicon.ico').to_s).size.zero?
      FileUtils.cp(Rails.root.join("app/assets/images/enju_leaf/favicon.ico"), Rails.root.join('public/favicon.ico'))
    end
    puts 'enju_leaf: Default asset file(s) are loaded successfully.'
  end

  desc 'Backfill migration versions before Next-L Enju Leaf 1.4'
  task :backfill_migration_versions => :environment do
    Rake::Task['enju_leaf:upgrade'].invoke
    Rake::Task['enju_leaf:upgrade'].reenable

    Dir.glob(Rails.root.join('db/migrate/*.rb')).each do |file|
      entry = File.basename(file).split('_', 3)
      table_name = entry[2].gsub(/\.rb\z/, '')
      version = entry[0].to_i

      # このバージョンより新しいマイグレーションファイルは対象外
      next if version >= 20201025090703

      # enju_bookmark
      next if [
        55, 20081212151614, 20081212151820, 20100222124420, 20140524135607,
        20140812093836, 20160815045420, 20180107172413,
        20180709023035, 20180709023036, 20180709023037, 20180709023038,
        20180709023039, 20180709023040, 20180709161346
      ].include?(version)

      # enju_news
      next if [
        20081031033632, 20090126071155, 20110220103937
      ].include?(version)

      # enju_biblio
      next if [
        20170116150432
      ].include?(version)

      # enju_ndl
      next if [
        20171126072934, 20190501043418
      ].include?(version)

      # enju_nii
      next if [
        20090913173236, 20090913185239
      ].include?(version)

      # enju_inventory
      next if [
        20081117143156, 20081117143455, 20090706125521, 20120413100431,
        20191224083828, 20191224091957, 20191230082846
      ].include?(version)

      # enju_purchase_request
      next if [
        123, 20081009062129, 20081009062130, 20140528155058, 20160703190738,
        20180107155817
      ].include?(version)

      next if ActiveRecord::Base.connection.select_one("SELECT version FROM schema_migrations WHERE version = '#{version.to_i}'")

      ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{version.to_i}')")
      puts "Added #{entry[0]}"
    end
  end

  desc 'Migrate attachments'
  task :migrate_attachments => :environment do
    if ENV['ENJU_STORAGE'] == 's3'
      migrate_attachment_s3
    else
      migrate_attachment
    end
  end

  desc 'Migrate identifiers'
  task :migrate_identifiers => :environment do
    IdentifierType.find_each do |identifier_type|
      Identifier.where(identifier_type: identifier_type).find_each do |identifier|
        Manifestation.transaction do
          case identifier_type.name
          when 'isbn'
            IsbnRecordAndManifestation.create!(
              manifestation: identifier.manifestation,
              isbn_record: IsbnRecord.find_by(body: identifier.body)
            )
          when 'issn'
            IssnRecordAndManifestation.create!(
              manifestation: identifier.manifestation,
              issn_record: IssnRecord.find_by(body: identifier.body)
            )
          when 'issn_l'
            IssnRecordAndManifestation.create!(
              manifestation: identifier.manifestation,
              issn_record: IssnRecord.find_by(body: identifier.body)
            )
          when 'jpno'
            JpnoRecord.create!(
              manifestation: identifier.manifestation,
              body: identifier.body
            )
          when 'iss_itemno'
            NdlBibIdRecord.create!(
              manifestation: identifier.manifestation,
              body: identifier.body
            )
          when 'ncid'
            NcidRecord.create!(
              manifestation: identifier.manifestation,
              body: identifier.body
            )
          when 'lccn'
            LccnRecord.create!(
              manifestation: identifier.manifestation,
              body: identifier.body
            )
          when 'doi'
            DoiRecord.create!(
              manifestation: identifier.manifestation,
              body: identifier.body
            )
          end

          # identifier.destroy
          Rails.logger.info "#{identifier_type.name} #{identifier.body} migrated"
        end
      end
    end
  end
end
