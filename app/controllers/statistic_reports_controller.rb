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
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1220, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
      end

      # daily average of checkout users all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.average_checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum/12)
      end
      # daily average of checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1223, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1210, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1210, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # checkout items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1210, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1210, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
      end

      # daily average of checkout items all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.average_checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1213, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1213, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum/12)
      end
      # daily average of checkout items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1213, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1213, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
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
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # reserves each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1330, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
        row.item("valueall").value(sum)
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # questions each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 1430, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
      end


      send_data report.generate, :filename => "#{term}_#{configatron.statistic_report.monthly}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end	
  end

  def get_daily_report
    term = params[:term]
    unless term =~ /^\d{6}$/
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = term
      render :index
      return false
    end
    libraries = Library.all
    logger.error "create daily statistic report: #{term}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/daily_report"

      [1,14,27].each do |start_date| # for 3 pages
        report.start_new_page do
          report.page.item(:year).value(term[0,4])
          report.page.item(:month).value(term[4,6])        
          # header
          if start_date != 27
            13.times do |t|
              report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}")
            end
          else
            5.times do |t|
              report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}")
            end
            report.page.list(:list).header.item("column#13").value(t('statistic_report.sum'))
          end
          # checkout users all libraries
          report.page.list(:list).add_row do |row|
            row.item(:type).value(t('statistic_report.checkout_users'))
            row.item(:library).value(t('statistic_report.all_library'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2220, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2220, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 2220, :library_id => 0)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # checkout users each libraries
          libraries.each do |library|
            report.page.list(:list).add_row do |row|
              row.item(:library).value(library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2220, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
              else
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2220, :library_id => 0).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => 2220, :library_id => 0)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
          # checkout items all libraries
          report.page.list(:list).add_row do |row|
            row.item(:type).value(t('statistic_report.checkout_items'))
            row.item(:library).value(t('statistic_report.all_library'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2210, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2210, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 2210, :library_id => 0)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # checkout items each libraries
          libraries.each do |library|
            report.page.list(:list).add_row do |row|
              row.item(:library).value(library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2210, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
              else
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2210, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => 2210, :library_id => 0)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
          # reserves all libraries
          report.page.list(:list).add_row do |row|
            row.item(:type).value(t('statistic_report.reserves'))
            row.item(:library).value(t('statistic_report.all_library'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2330, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else  
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2330, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 2330, :library_id => 0)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # reserves each library
          libraries.each do |library|
            report.page.list(:list).add_row do |row|
              row.item(:library).value(library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2330, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
              else  
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2330, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => 2330, :library_id => 0)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
          # questions all libraries
          report.page.list(:list).add_row do |row|
            row.item(:type).value(t('statistic_report.questions'))
            row.item(:library).value(t('statistic_report.all_library'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2430, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end  
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2430, :library_id => 0).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0              
              datas = Statistic.where(:yyyymm => term, :data_type => 2430, :library_id => 0)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # questions each library
          libraries.each do |library|
            report.page.list(:list).add_row do |row|
              row.item(:library).value(library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2430, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end  
              else
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i + 1}#{"%02d" % (t + start_date)}", :data_type => 2430, :library_id => library.id).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => 2430, :library_id => 0)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
        end 
      end
      send_data report.generate, :filename => "#{term}_#{configatron.statistic_report.daily}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def get_timezone_report
    #default setting 9 - 20
    open = configatron.statistic_report.open
    hours = configatron.statistic_report.hours

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
    logger.error "create daily timezone report: #{start_at} - #{end_at}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/timezone_report"
      report.start_new_page
       
      report.page.item(:year).value(start_at[0,4])
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,6])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,6])

      # header 
      12.times do |t|
        report.page.list(:list).header.item("column##{t+1}").value("#{t+open}#{t('statistic_report.hour')}")
      end
      report.page.list(:list).header.item("column#13").value(t('statistic_report.sum'))

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3220 AND library_id = ? AND hour = ?", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3220 AND library_id = ? AND hour = ?", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
      end
      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3210 AND library_id = ? AND hour = ?", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3210 AND library_id = ? AND hour = ?", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3330 AND library_id = ? AND hour = ?", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3330 AND library_id = ? AND hour = ?", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3430 AND library_id = ? AND hour = ?", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 3430 AND library_id = ? AND hour = ?", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
      end

      send_data report.generate, :filename => "#{start_at}_#{end_at}__#{configatron.statistic_report.timezone}", :type => 'application/pdf', :disposition => 'attachment'
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
    logger.error "create day statistic report: #{start_at} - #{end_at}"

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

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2210 AND library_id = ? AND day = ?", 0, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 2210 AND library_id = ? AND day = ?", library.id, t])
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
