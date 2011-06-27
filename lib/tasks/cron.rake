desc 'Import records'
task :cron => :environment do
  ResourceImportFile.import
  PatronImportFile.import
  EventImportFile.import
  Manifestation.rss_import('http://iss.ndl.go.jp/rss/inprocess/7.xml')
end
