class GenerateItemListJob < Struct.new(:job_name, :file_name, :file_type, :method, :dumped_query, :args, :user)
  include Rails.application.routes.url_helpers
  include BackgroundJobUtils

  def perform
    user_file = UserFile.new(user)

    # get data
    query = Marshal.load(dumped_query)
    logger.info "SQL start at #{Time.now}"
    items = query.all
    logger.info "SQL end at #{Time.now}\nfound #{items.length rescue 0} records"
    logger.info "list_type=#{file_name} file_type=#{file_type}"

    data = Item.__send__("#{method}_#{file_type}", items, *args)
    if file_type == 'pdf'
      raise I18n.t('item_list.no_record') unless data
      data = data.generate
    end

    io, info = user_file.create(:item_list, "#{file_name}.#{file_type}")
    begin
      io.print data
    ensure
      io.close
    end

    url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
    message(
      user,
      I18n.t('item_list.export_job_success_subject', :job_name => job_name),
      I18n.t('item_list.export_job_success_body', :job_name => job_name, :url => url))

  rescue => exception
    message(
      user,
      I18n.t('item_list.export_job_error_subject', :job_name => job_name),
      I18n.t('item_list.export_job_error_body', :job_name => job_name, :message => exception.message))
  end
end
