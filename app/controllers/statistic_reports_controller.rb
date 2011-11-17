class StatisticReportsController < ApplicationController
  require 'thinreports'
  before_filter :check_role

  def index
    @year = Time.zone.now.years_ago(1).strftime("%Y")
    @month = Time.zone.now.months_ago(1).strftime("%Y%m")
  end

  # check role
  def check_role
    unless current_user.try(:has_role?, 'Librarian')
      access_denied; return
    end
  end

  def get_monthly_report
    term = params[:term]
    unless term =~ /^\d{4}$/
      flash[:message] = t('statistic_report.invalid_year')
      @year = term
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      render :index
      return false
    end
    libraries = Library.all
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/monthly_report"
      report.start_new_page
       
      report.page.item(:term).value(term)

      # items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.items'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1110, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1110, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1110, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1110, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end

      # daily average of checkout users all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.average_checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # daily average of checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end

      # all users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.users'))
        row.item(:library).value(t('statistic_report.all_library'))
        row.item(:option).value(t('statistic_report.all_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1120, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1120, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # unlocked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.unlocked_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1121, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1121, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # locked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.locked_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1122, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1122, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end

      # users each library
      libraries.each do |library|
        # all users
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          row.item(:option).value(t('statistic_report.all_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1120, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1120, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
        # unlocked users
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.unlocked_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1121, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1121, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
        # locked users
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.locked_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1122, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1122, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # reserves each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # questions each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
      end


      send_data report.generate, :filename => "#{term}_#{configatron.statistic_report.monthly}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end	
  end

  def get_day_report
    start_at = params[:start_at]
    end_at = params[:end_at]
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{6}$/ && end_at =~ /^\d{6}$/) && start_at.to_i <= end_at.to_i 
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @start_at = start_at
      @end_at = end_at
      render :index
      return false
    end
    libraries = Library.all
    logger.error "creating statistic: #{start_at} - #{end_at}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/day_report"
      report.start_new_page
       
      report.page.item(:year).value(start_at[0,4])
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,6])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,6])


      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2220 AND library_id = ? AND day = ?", 0, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2220 AND library_id = ? AND day = ?", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2330 AND library_id = ? AND day = ?", 0, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2330 AND library_id = ? AND day = ?", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2430 AND library_id = ? AND day = ?", 0, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2430 AND library_id = ? AND day = ?", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
      end


      send_data report.generate, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.day}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end
end
