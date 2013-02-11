class GenerateItemRegisterJob < Struct.new(:job_name, :file_name, :file_type, :method, :args, :user)
  include Rails.application.routes.url_helpers
  include BackgroundJobUtils

  def perform
    fn = "#{file_name}.#{file_type}"
    user_file = UserFile.new(user)
    url = nil

    logger.error "SQL start at #{Time.now}"

    Dir.mktmpdir do |tmpdir|
      Item.__send__(method, *args, tmpdir + '/', file_type)

      o, info = user_file.create(:item_register, fn)
      begin
        open(File.join(tmpdir, fn)) do |i|
          FileUtils.copy_stream(i, o)
        end
      ensure
        o.close
      end

      url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
    end

    message(
      user,
      I18n.t('item_register.export_job_success_subject', :job_name => job_name),
      I18n.t('item_register.export_job_success_body', :job_name => job_name, :url => url))

    logger.error "created report: #{Time.now}"

  rescue => exception
    message(
      user,
      I18n.t('item_register.export_job_error_subject', :job_name => job_name),
      I18n.t('item_register.export_job_error_body', :job_name => job_name, :message => exception.message))
  end
end
