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
    Rake::Task['db:migrate'].invoke

    Dir.glob(Rails.root.join('db/migrate/*.rb')).each do |file|
			entry = File.basename(file).split('_', 3)
      table_name = entry[2].gsub(/\.rb\z/, '')
      version = entry[0].to_i

      # このバージョンより新しいマイグレーションファイルは対象外
      next if version > 20201025090703

      next if ActiveRecord::Base.connection.exec_query('SELECT version FROM schema_migrations WHERE version = $1', 'SQL', [[nil, version]]).first

      ActiveRecord::Base.connection.exec_query('INSERT INTO schema_migrations (version) VALUES ($1)', 'SQL', [[nil, version]])
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
    isbn = IdentifierType.find_by(name: 'isbn')
    Identifier.where(identifier_type: isbn).find_each do |identifier|
      IsbnRecordAndManifestation.create(
        manifestation: identifier.manifestation,
        isbn_record: IsbnRecord.find_by(body: identifier.body)
      )
    end

    issn = IdentifierType.find_by(name: 'issn')
    Identifier.where(identifier_type: issn).find_each do |identifier|
      IssnRecordAndManifestation.create(
        manifestation: identifier.manifestation,
        issn_record: IssnRecord.find_by(body: identifier.body)
      )
    end

    issn_l = IdentifierType.find_by(name: 'issn_l')
    Identifier.where(identifier_type: issn).find_each do |identifier|
      IssnRecordAndManifestation.create(
        manifestation: identifier.manifestation,
        issn_record: IssnRecord.find_by(body: identifier.body)
      )
    end

    jpno = IdentifierType.find_by(name: 'jpno')
    Identifier.where(identifier_type: jpno).find_each do |identifier|
      JpnoRecord.create(
        manifestation: identifier.manifestation,
        body: identifier.body
      )
    end

    iss_itemno = IdentifierType.find_by(name: 'iss_itemno')
    Identifier.where(identifier_type: jpno).find_each do |identifier|
      NdiBibIdRecord.create(
        manifestation: identifier.manifestation,
        body: identifier.body
      )
    end

    ncid = IdentifierType.find_by(name: 'ncid')
    Identifier.where(identifier_type: ncid).find_each do |identifier|
      NcidRecord.create(
        manifestation: identifier.manifestation,
        body: identifier.body
      )
    end

    lccn = IdentifierType.find_by(name: 'lccn')
    Identifier.where(identifier_type: lccn).find_each do |identifier|
      LccnRecord.create(
        manifestation: identifier.manifestation,
        body: identifier.body
      )
    end

    doi = IdentifierType.find_by(name: 'doi')
    Identifier.where(identifier_type: doi).find_each do |identifier|
      DoiRecord.create(
        manifestation: identifier.manifestation,
        body: identifier.body
      )
    end
  end
end
