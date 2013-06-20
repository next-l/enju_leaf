class Checkoutlist < ActiveRecord::Base
  paginates_per 10

  def self.get_checkoutlist(output_type, current_user, circulation_status_ids, &block)
    total_count = Item.count_by_sql("select count(*) from items where circulation_status_id in (#{circulation_status_ids.join(',')})")
    threshold ||= Setting.background_job.threshold.export rescue 0

    if total_count > threshold
      user_file = UserFile.new(current_user)
      io, info = user_file.create(:checkoutlist, 'checkoutlist.tmp')

      job_name = GenerateCheckoutlistJob.generate_job_name
      Delayed::Job.enqueue GenerateCheckoutlistJob.new(job_name, info, output_type, current_user, circulation_status_ids)
      output = OpenStruct.new
      output.result_type = :delayed
      output.job_name = job_name
      block.call(output)
      return
    end
    generate_checkoutlist(output_type, circulation_status_ids, &block)
  end

  def self.generate_checkoutlist(output_type, circulation_status_ids, &block)
    output = OpenStruct.new
    output.result_type = :data

    case output_type
    when 'pdf'
      method = 'get_checkoutlists_pdf'
    when 'tsv'
      method = 'get_checkoutlists_tsv'
    else
      raise 'unknown output type'
    end
    filename_method = method.sub(/\Aget_(.*)s_*(_.*)\z/){ "#{$1}_report#{$2}" }
    output.filename = Setting.__send__(filename_method).filename
 
    dispList = Struct.new(:circulation_status, :items)
    @displist = []
    circulation_status_ids.each do |c|
      items = Item.find(:all, :joins => [:manifestation, :circulation_status, :shelf => :library], :conditions => { :circulation_status_id => c }, :order => 'libraries.id, items.shelf_id, items.item_identifier')
      @displist << dispList.new(CirculationStatus.find(c).display_name.localize, items)
    end
 
    result = output.__send__("#{output.result_type}=", Checkout.__send__(method, @displist))
    output.data = /_pdf\z/ =~ method ? result.generate : result
    block.call(output)
  end

  class GenerateCheckoutlistJob
    include Rails.application.routes.url_helpers
    include BackgroundJobUtils

    def initialize(name, fileinfo, output_type, user, circulation_status_ids)
      @name = name
      @output_type = output_type
      @user = user
      @circulation_status_ids = circulation_status_ids
      @fileinfo = fileinfo
    end
    attr_accessor :name, :fileinfo, :output_type, :user, :circulation_status_ids

    def perform
      user_file = UserFile.new(user)
      path, = user_file.find(fileinfo[:category], fileinfo[:filename], fileinfo[:random])

      Checkoutlist.generate_checkoutlist(output_type, circulation_status_ids) do |output|
        io, info = user_file.create(:checkoutlist, output.filename)
        if output.result_type == :path
          open(output.path) {|io2| FileUtils.copy_stream(io2, io) }
        else
          io.print output.data
        end
        io.close

        url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
        message(
          user,
          I18n.t('checkoutlist.output_job_success_subject', :job_name => name),
          I18n.t('checkoutlist.output_job_success_body', :job_name => name, :url => url))
      end

    rescue => exception
      message(
        user,
        I18n.t('checkoutlist.output_job_error_subject', :job_name => name),
        I18n.t('checkoutlist.output_job_error_body', :job_name => name, :message => exception.message+exception.backtrace))
    end
  end
end
