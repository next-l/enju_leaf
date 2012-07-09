namespace :reindex do
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
