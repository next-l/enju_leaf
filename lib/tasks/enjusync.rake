require 'digest/sha1'

INIT_BUCKET = "/opt/enju_trunk/script/tools/sync/init-bucket.pl"
SEND_BUCKET = "/opt/enju_trunk/script/tools/sync/send-bucket.pl"
DUMPFILE_PREFIX = "/var/enjusync"
PERLBIN = "/usr/bin/perl"

def taglogger(head, tag, msg)
  Rails.logger.info "#{head} #{tag} #{msg}"
end

def ftpsyncpush(last_id)
  taglogger head, tag, "call task [init_backet] start"
  sh "#{PERLBIN} #{INIT_BUCKET} #{last_id}"
  taglogger head, tag, "call task [init_backet] end"

  taglogger head, tag, "call task [send_backet] start"
  sh "#{PERLBIN} #{SEND_BUCKET}"
  taglogger head, tag, "call task [send_backet] end"
end

namespace :enju_trunk do
  namespace :sync do
    desc 'Initial sync'
    task :init => :environment do
      head = "sync::init"
      tag = Digest::SHA1.hexdigest(Time.now.strftime('%s'))[-5, 5]

      taglogger head, tag, "start #{Time.now}"
      taglogger head, tag, "init_bucket=#{INIT_BUCKET}"
      taglogger head, tag, "send_bucket=#{SEND_BUCKET}"

      last_id = Version.last.id
      dumpfiledir = "#{DUMPFILE_PREFIX}/#{last_id}"
      dumpfile = "#{dumpfiledir}/enjudump.yml"

      taglogger head, tag, "last_id=#{last_id} "
      taglogger head, tag, "dumpfiledir=#{dumpfiledir} "
      taglogger head, tag, "dumpfile=#{dumpfile} "

      taglogger head, tag, "mkdir_p begin"
      FileUtils.mkdir_p(dumpfiledir)
      taglogger head, tag, "mkdir_p end"

      taglogger head, tag, "call task [enju::sync::export] start"

      Rake::Task["enju:sync:export"].invoke("DUMP_FILE=#{dumpfile} EXPORT_FROM=#{last_id}")

      taglogger head, tag, "call task [enju::sync::export] end"

      ftpsyncpush(last_id) 

      taglogger head, tag, "end (NormalEnd)"
    end

    desc 'Scheduled process'
    task :scheduled_export => :environment do
      head = "sync::scheduled_export"
      tag = Digest::SHA1.hexdigest(Time.now.strftime('%s'))[-5, 5]

      taglogger head, tag, "start #{Time.now}"
      taglogger head, tag, "init_bucket=#{INIT_BUCKET}"
      taglogger head, tag, "send_bucket=#{SEND_BUCKET}"

      last_id = Version.last.id
      dumpfiledir = "#{DUMPFILE_PREFIX}/#{last_id}"
      dumpfile = "#{dumpfiledir}/enjudump.yml"

      # a.業務側からWebOPAC側に接続し、5)のstatusfileを取得
      # TODO
      
      # b.同期番号取得
      last_id = Version.last.id

      # c.同期データを出力
      Rake::Task["enju:sync:export"].invoke("DUMP_FILE=#{dumpfile} STATUSFILE=#{statusfile}")

      # d.バケット作成, e.データ転送
      ftpsyncpush(last_id) 
    end

    desc 'Scheduled process'
    task :scheduled_import => :enviroment do
      # rake enju:sync:import DUMP_FILE=path/to/dumpfile.yml STATUS_FILE=path/to/statusfile.yml
    end
  end
end
