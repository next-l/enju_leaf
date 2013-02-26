# based on Sunspot::Rails::Searchable.solr_index
# (sunspot_rails-2.0.0.pre.130115/lib/sunspot/rails/searchable.rb)
module Sunspot
  module Rails
    module Searchable
      module ActsAsMethods									
	def solr_index_parallel(opts={})
          
          options = {
            :batch_size => Sunspot.config.indexing.default_batch_size,
            :batch_commit => true,
            :include => self.sunspot_options[:include],
            :start => opts.delete(:first_id) || 0
          }.merge(opts)
          
          find_in_batch_options = {
            :include => options[:include],
            :batch_size => options[:batch_size],
            :start => options[:start]
          }
          
          exec_processor_size = options[:exec_processor_size]
          progress_bar = options[:progress_bar]
          
          mutex = Mutex.new
          tcount = exec_processor_size
	  
          if options[:batch_size]
            batch_counter = 0
            ths = []
            find_in_batches(find_in_batch_options) do |records|
              while tcount < 1 do
                #sleep 5
		Thread.pass
              end
	      mutex.synchronize {tcount -= 1}
              solr_benchmark options[:batch_size], batch_counter do
                ths << Thread.start do
		  begin
                    #puts "Thread #{tcount} of #{exec_processor_size}"
                    Sunspot.index(records.select { |r| r.indexable? })
                    Sunspot.commit if options[:batch_commit]
		  ensure
                    mutex.synchronize {tcount += 1}
                    Thread.exit
		  end
                end
                # track progress
                progress_bar.increment!(records.length) if progress_bar
                batch_counter += 1
              end
            end
            ths.each {|t| t.join}
          else
            records = all(:include => options[:include]).select { |model| model.indexable? }
            Sunspot.index!(records)
          end
          # perform a final commit if not committing in batches
          Sunspot.commit unless options[:batch_commit]
        end
      end
    end
  end
end

namespace :enju_trunk do
  namespace :reindex do
    desc "Reindex all model (by model)" 
    task :parallelbymodel, [:exec_processor_size] => :environment do |t, args|
      Sunspot.session = Sunspot::SessionProxy::Retry5xxSessionProxy.new(Sunspot.session)
      reindex_options = { :batch_commit => false, :exec_processor_size => 1 }

      require "parallel"
      require "benchmark"

      case args[:exec_processor_size]
      when 'false'
        reindex_options[:exec_processor_size] = 1
      when /^\d+$/ 
        reindex_options[:exec_processor_size] = args[:exec_processor_size].to_i if args[:exec_processor_size].to_i > 0
      end

      puts "#{Parallel.processor_count} procesor(s)"
      puts "reindex using #{reindex_options[:exec_processor_size]} thread(s)"

      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      sunspot_models = Sunspot.searchable
      total_documents = sunspot_models.map { | m | m.count }.sum
      sorted_models = sunspot_models.sort{|a, b| a.count <=> b.count} 

      # Set up progress_bar to, ah, report progress
      begin
        require 'progress_bar'
        reindex_options[:progress_bar] = ProgressBar.new(total_documents)
      rescue LoadError => e
        $stdout.puts "Skipping progress bar: for progress reporting, add gem 'progress_bar' to your Gemfile"
      rescue Exception => e
        $stderr.puts "Error using progress bar: #{e.message}"
      end

      $stdout.puts "Reindex model list:"
      sorted_models.each { |model|
        $stdout.puts " name=#{model.name} record_size=#{model.count}"
      }
      $stdout.flush

      Benchmark.bm do |x|
        x.report('thread') {
          results = Parallel.map(sorted_models, :in_threads => reindex_options[:exec_processor_size]) { |model|
            #$stdout.puts "#{model.name} #{model.class}"
            #$stdout.puts "name=#{model.name} size=#{model.count}"
          
            model.solr_reindex(reindex_options)
          }
        }
      end
    end

    desc "Reindex all model (paralleled by record)" 
    task :parallelbyrecord, [:exec_processor_size,:batch_size] => :environment do |t, args|
      Sunspot.session = Sunspot::SessionProxy::Retry5xxSessionProxy.new(Sunspot.session)
      reindex_options = { :batch_commit => false,
                          :exec_processor_size => 1, 
			  :batch_size => 1000 }

      case args[:exec_processor_size]
      when 'false'
        reindex_options[:exec_processor_size] = 1
      when /^\d+$/ 
        reindex_options[:exec_processor_size] = args[:exec_processor_size].to_i if args[:exec_processor_size].to_i > 0
      end

      case args[:batch_size]
      when 'false'
        reindex_options[:batch_size] = 1000
      when /^\d+$/ 
        reindex_options[:batch_size] = args[:batch_size].to_i if args[:batch_size].to_i > 0
      end

      puts "#{Parallel.processor_count} procesor(s)"
      puts "reindex using #{reindex_options[:exec_processor_size]} procesor(s)"

      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      sunspot_models = Sunspot.searchable
      total_documents = sunspot_models.map { | m | m.count }.sum
      sorted_models = sunspot_models.sort{|a, b| a.count <=> b.count} 

      # Set up progress_bar to, ah, report progress
      begin
        require 'progress_bar'
        reindex_options[:progress_bar] = ProgressBar.new(total_documents)
      rescue LoadError => e
        $stdout.puts "Skipping progress bar: for progress reporting, add gem 'progress_bar' to your Gemfile"
      rescue Exception => e
        $stderr.puts "Error using progress bar: #{e.message}"
      end

      $stdout.puts "Reindex model list:"
      sorted_models.each { |model|
        $stdout.puts " name=#{model.name} record_size=#{model.count}"
      }
      $stdout.flush

      sorted_models.each do |model|
        model.solr_remove_all_from_index
        model.solr_index_parallel(reindex_options)
      end
    end

    desc "Reindex a manifestations"
    task :manifestations => :environment do
      request_reindex Manifestation 
    end

    desc "Reindex a items"
    task :items => :environment do
      request_reindex Item
    end

    desc "Reindex a users"
    task :users => :environment do
      request_reindex User 
    end

    desc "Reindex manifestations,users, and users"
    task :all => [:manifestations, :items, :users]

    def request_reindex(model_class)
      require 'ostruct'
      thread_list = []
      thread_control = []
      record = model_class.search.total #10000
      split_number = 3
      width_num = (record / split_number.to_f).ceil
      puts "Total of #{model_class}: #{record}"
      puts "w=#{width_num}"

      split_number.times do |i|
        t = OpenStruct.new
        t.start_index = (record / split_number.to_f).ceil * i + 1
        t.end_index = (record / split_number.to_f).ceil * (i + 1) #- 1
        thread_control << t
      end

      puts "Start reindex #{model_class}!"

      require "parallel"
      require "benchmark"

      puts "#{Parallel.processor_count} procesor(s)"

      Benchmark.bm do |x|
        x.report('thread') {
          results = Parallel.map(thread_control, :in_threads => split_number) { |t|
          puts  "start=#{t.start_index} end=#{t.end_index}"
          model_class.where("id between #{t.start_index} and #{t.end_index}").find_each do |m| m.index end
        }
        }
      end

      thread_list.map { |t| t.join } 
      puts "End reindex #{model_class}!"
    end
  end
end
