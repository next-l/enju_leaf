# encoding: utf-8

namespace :enju do
  namespace :sync do
    desc 'export for synchronization'
    task :export => :environment do
      if ENV['STATUS_FILE']
        Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
        status = Marshal.load(File.read(ENV['STATUS_FILE']))
        last_event_id = status[:last_event_id]
        unless last_event_id
          fail 'no id in the status file, please specify STATUS_FILE=path/to/previous_file or EXPORT_FROM=N'
        end
      elsif ENV['EXPORT_FROM']
        last_event_id = Integer(ENV['EXPORT_FROM'])
      else
        fail 'please specify STATUS_FILE=path/to/file or EXPORT_FROM=N'
      end

      unless ENV['DUMP_FILE']
        fail 'please specify DUMP_FILE=path/to/file'
      end

      dump = Version.export_for_incremental_synchronization(last_event_id)

      if dump[:versions].empty?
        $stderr.puts "no changes found"

      else
        open(ENV['DUMP_FILE'], 'w') do |io|
          unless io.flock(File::LOCK_EX|File::LOCK_NB)
            fail "another process is writing to #{ENV['DUMP_FILE']}"
          end
          Marshal.dump(dump, io)
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

      status = nil

      open(ENV['DUMP_FILE'], 'r') do |df|
        unless df.flock(File::LOCK_EX|File::LOCK_NB)
          fail "another process is writing to #{ENV['DUMP_FILE']}"
        end

        dump = Marshal.load(File.read(df))

        if dump[:versions].empty?
          $stderr.puts "no changes found"

        else
          open(ENV['STATUS_FILE'], 'w:binary') do |io|
            unless io.flock(File::LOCK_EX|File::LOCK_NB)
              fail "another process is writing to #{ENV['STATUS_FILE']}"
            end
            status = Version.import_for_incremental_synchronization!(dump)
            Marshal.dump(status, io)
          end
        end
      end

      unless status[:success]
        failed_event = status[:failed_event]
        fail "import failed on \"#{failed_event[:event_type]} #{failed_event[:item_type]}\##{failed_event[:item_id]}\" (Version\##{status[:failed_event_id]}): #{status[:exception][:message]} (#{status[:exception][:class].name})"
      end
    end
  end
end
