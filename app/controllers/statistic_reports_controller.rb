class StatisticReportsController < ApplicationController
  before_filter :check_role

  def index
    @year = Time.zone.now.years_ago(1).strftime("%Y")
    @month = Time.zone.now.months_ago(1).strftime("%Y%m")
    @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
    @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
    @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
    @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
    @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
    @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
    @items_year = Time.zone.now.years_ago(1).strftime("%Y")
    @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
    @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
    @group_term = Time.zone.now.years_ago(1).strftime("%Y")
  end

  # check role
  def check_role
    unless current_user.try(:has_role?, 'Librarian')
      access_denied; return
    end
  end

  def get_monthly_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/
      flash[:message] = t('statistic_report.invalid_year')
      @year = term
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if params[:tsv]
      file = StatisticReport.get_monthly_report_tsv(term)
      send_file file, :filename => "#{term}_#{configatron.statistic_report.monthly_tsv}", :type => 'application/tsv', :disposition => 'attachment'
    else
      file = StatisticReport.get_monthly_report_pdf(term)
      send_data file, :filename => "#{term}_#{configatron.statistic_report.monthly}", :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def get_daily_report
    term = params[:term].strip
    unless term =~ /^\d{6}$/ && month_term?(term)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = term
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if params[:tsv]
      file = StatisticReport.get_daily_report_tsv(term)
      send_file file, :filename => "#{term}_#{configatron.statistic_report.daily_tsv}", :type => 'application/tsv', :disposition => 'attachment'
    else
      file = StatisticReport.get_daily_report_pdf(term)
      send_data file, :filename => "#{term}_#{configatron.statistic_report.daily}", :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def get_timezone_report
    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{8}$/ && end_at =~ /^\d{8}$/) && start_at.to_i <= end_at.to_i && term_valid?(start_at) && term_valid?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = start_at
      @t_end_at = end_at
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if params[:tsv]
      file = StatisticReport.get_timezone_report_tsv(start_at, end_at)
      send_file file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.timezone_tsv}", :type => 'application/tsv', :disposition => 'attachment'
    else
      file = StatisticReport.get_timezone_report_pdf(start_at, end_at)
      send_data file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.timezone}", :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def get_day_report
    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{8}$/ && end_at =~ /^\d{8}$/) && start_at.to_i <= end_at.to_i && term_valid?(start_at) && term_valid?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = start_at
      @d_end_at = end_at
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if params[:tsv]
      file = StatisticReport.get_day_report_tsv(start_at, end_at)
      send_file file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.day_tsv}", :type => 'application/tsv', :disposition => 'attachment'
    else
      file = StatisticReport.get_day_report_pdf(start_at, end_at)
      send_data file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.day}", :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def get_age_report
    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{8}$/ && end_at =~ /^\d{8}$/) && start_at.to_i <= end_at.to_i && term_valid?(start_at) && term_valid?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = start_at
      @a_end_at = end_at
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if params[:tsv]
      file = StatisticReport.get_age_report_tsv(start_at, end_at)
      send_file file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.age_tsv}", :type => 'application/tsv', :disposition => 'attachment'
    else
      file = StatisticReport.get_age_report_pdf(start_at, end_at)
      send_data file, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.age}", :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def get_items_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/ || (term =~ /^\d{6}$/ && month_term?(term))
      flash[:message] = t('statistic_report.invalid_year')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = term
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if term =~ /^\d{4}$/
      if params[:tsv]
        file = StatisticReport.get_items_monthly_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.items_tsv}", :type => 'application/tsv', :disposition => 'attachment'
      else
        file = StatisticReport.get_items_monthly_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.items}", :type => 'application/pdf', :disposition => 'attachment'
      end
    else
      if params[:tsv]
        file = StatisticReport.get_items_daily_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.items_tsv}", :type => 'application/tsv', :disposition => 'attachment'
      else
        file = StatisticReport.get_items_daily_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.items}", :type => 'application/pdf', :disposition => 'attachment'
      end	
    end
  end

  def get_inout_items_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/ || (term =~ /^\d{6}$/ && month_term?(term))
      flash[:message] = t('statistic_report.invalid_year')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = term
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if term =~ /^\d{4}$/
      if params[:tsv]
        file = StatisticReport.get_inout_monthly_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.inout_items_tsv}", :type => 'application/tsv', :disposition => 'attachment' 
      else
        file = StatisticReport.get_inout_monthly_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.inout_items}", :type => 'application/pdf', :disposition => 'attachment'
      end
    else
      if params[:tsv]
        file = StatisticReport.get_inout_daily_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.inout_items_tsv}", :type => 'application/tsv', :disposition => 'attachment'
      else
        file = StatisticReport.get_inout_daily_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.inout_items}", :type => 'application/pdf', :disposition => 'attachment'
      end
    end
  end

  def get_loans_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/ || (term =~ /^\d{6}$/ && month_term?(term))
      flash[:message] = t('statistic_report.invalid_year')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = term
      @group_term = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    if term =~ /^\d{4}$/
      if params[:tsv]
        file = StatisticReport.get_loans_monthly_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.loans_tsv}", :type => 'application/tsv', :disposition => 'attachment'
      else
        file = StatisticReport.get_loans_monthly_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.loans}", :type => 'application/pdf', :disposition => 'attachment'
      end
    else
      if params[:tsv]
        file = StatisticReport.get_loans_daily_tsv(term)
        send_file file, :filename => "#{term}_#{configatron.statistic_report.loans_tsv}", :type => 'application/tsv', :disposition => 'attachment'
      else
        file = StatisticReport.get_loans_daily_pdf(term)
        send_data file, :filename => "#{term}_#{configatron.statistic_report.loans}", :type => 'application/pdf', :disposition => 'attachment'       
      end
    end
  end

  def get_groups_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/ || (term =~ /^\d{6}$/ && month_term?(term))
      flash[:message] = t('statistic_report.invalid_year')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = term
      render :index
      return false
    end
    if term =~ /^\d{4}$/
      if params[:tsv]
        file = StatisticReport.get_groups_monthly_tsv(term)
        if file
          send_file file, :filename => "#{term}_#{configatron.statistic_report.groups_tsv}", :type => 'application/tsv', :disposition => 'attachment'
        else
          raise
        end
      else
        file = StatisticReport.get_groups_monthly_pdf(term)
        if file
          send_data file, :filename => "#{term}_#{configatron.statistic_report.groups}", :type => 'application/pdf', :disposition => 'attachment'
        else
          raise
        end
      end
    else
      if params[:tsv]
        file = StatisticReport.get_groups_daily_tsv(term)
        if file
          send_file file, :filename => "#{term}_#{configatron.statistic_report.groups_tsv}", :type => 'application/tsv', :disposition => 'attachment'
        else
          raise
        end
      else
        file = StatisticReport.get_groups_daily_pdf(term)
        if file
          send_data file, :filename => "#{term}_#{configatron.statistic_report.groups}", :type => 'application/pdf', :disposition => 'attachment'       
        else
          raise
        end
      end
    end
    rescue 
      flash[:message] = t('statistic_report.no_corporate')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @t_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @d_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @d_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @a_start_at = Time.zone.now.months_ago(1).beginning_of_month.strftime("%Y%m%d")
      @a_end_at = Time.zone.now.months_ago(1).end_of_month.strftime("%Y%m%d")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      @inout_term = Time.zone.now.years_ago(1).strftime("%Y")
      @loans_term = Time.zone.now.years_ago(1).strftime("%Y")
      @group_term = term
      render :index
      return false      
  end

private
  def month_term?(term)
	    begin 
      Time.parse("#{term}01")
      return true
    rescue ArgumentError
      return false
    end
  end

  def term_valid?(term)
    begin 
      return false unless Time.parse("#{term}").strftime("%Y%m%d") == term
      return true
    rescue ArgumentError
      return false
    end
  end

end
