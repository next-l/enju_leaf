class AccessLog < ActiveRecord::Base
  validates_uniqueness_of :date, :scope => [:log_type]

  def self.calc(date = Time.now.to_s)
    # log_file = "#{Rails.root}/log/development.log"
    log_file = "#{Rails.root}/log/production.log"

    require "time"
    date = Time.parse(date).strftime("%Y-%m-%d")

    puts "start calc for a access log: #{date}"
    # TOP page
    str = "Processing by PageController#index as HTML"
    access_log = AccessLog.new
    access_log.date = date
    access_log.log_type = "top_access"
    value = grep_num(date, str, log_file)
    str = "Processing by MyAccountsController#show as HTML"
    access_log.value = value + grep_num(date, str, log_file)
    access_log.save

    # Manifestations index
    str = "Processing by ManifestationsController#index as HTML"
    access_log = AccessLog.new
    access_log.date = date
    access_log.log_type = "manifestations_index"
    access_log.value = grep_num(date, str, log_file)
    access_log.save

    # Materials show
    str = "Processing by ManifestationsController#show as HTML"
    access_log = AccessLog.new
    access_log.date = date
    access_log.log_type = "manifestations_show"
    access_log.value = grep_num(date, str, log_file)
    access_log.save
  end

  def self.create_hash
    datas = Hash.new
    logs = AccessLog.find(:all, 
      :select => "to_char(date, 'yyyy/mm') as month, log_type, sum(value) as sum",
      :group => "to_char(date, 'yyyy/mm'), log_type",
      :order => "to_char(date, 'yyyy/mm')")
    logs.each do |log|
      datas[:"#{log.month}"] = Hash.new unless datas[:"#{log.month}"]
      datas[:"#{log.month}"][:"#{log.log_type}"] = log.sum
    end
    return datas
  end

  def self.calc_sum_yesterday
    date = Time.now.yesterday.strftime("%Y%m%d")
    calc(date)
  end

  private
  def self.grep_num(date, str, filename)
    num = 0
    date_line = ''

    File.open(filename) do |f|
      while line = f.gets
       if /#{str}/ =~ line.encode("UTF-8", "UTF-8", invalid: :replace, undef: :replace, replace: '.') 
         if /^Started GET/ =~ date_line.encode("UTF-8", "UTF-8", invalid: :replace, undef: :replace, replace: '.')
           if /#{date}/ =~ date_line.encode("UTF-8", "UTF-8", invalid: :replace, undef: :replace, replace: '.')
             num += 1
           end
         end
       end
       date_line = line
     end 
    end
    return num
  end
end
