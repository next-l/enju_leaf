namespace :enju do
  namespace :sync do
    desc 'export for synchronization'
    task :export => :environment do
      if ENV['STATUS_FILE']
        status = YAML.load_file(ENV['STATUS_FILE'])
        last_event_time = status[:last_event_time]
      elsif ENV['EXPORT_FROM']
        last_event_time = Time.parse(ENV['EXPORT_FROM'])
      else
        fail 'please specify STATUS_FILE=path/to/file or EXPORT_FROM="YYYY-MM-DD hh:mm:ss"'
      end

      unless ENV['DUMP_FILE']
        fail 'please specify DUMP_FILE=path/to/file'
      end

      dump = Version.export_for_incremental_synchronization(last_event_time)

      if dump[:versions].empty?
        $stderr.puts "no changes found"

      else
        open(ENV['DUMP_FILE'], 'w') do |io|
          unless io.flock(File::LOCK_EX|File::LOCK_NB)
            fail "another process is writing to #{ENV['DUMP_FILE']}"
          end
          YAML.dump(dump, io)
        end
      end
    end

    desc 'import for synchronization'
    task :import => :environment do
      unless ENV['DUMP_FILE']
        fail 'please specify DUMP_FILE=path/to/file'
      end

      unless ENV['STATUS_FILE']
        fail 'please specify STATUS_FILE=path/to/file'
      end

      open(ENV['DUMP_FILE'], 'r') do |df|
        unless df.flock(File::LOCK_EX|File::LOCK_NB)
          fail "another process is writing to #{ENV['DUMP_FILE']}"
        end

        dump = YAML.load(df)

        if dump[:versions].empty?
          $stderr.puts "no changes found"

        else
          open(ENV['STATUS_FILE'], 'w') do |io|
            unless io.flock(File::LOCK_EX|File::LOCK_NB)
              fail "another process is writing to #{ENV['STATUS_FILE']}"
            end
            status = Version.import_for_incremental_synchronization!(dump)
            YAML.dump(status, io)
          end
        end
      end
    end
  end
end
