class StatisticReportsController < ApplicationController
  require 'thinreports'

  def index
  end

  def monthly_data
  end

  def get_monthly_report
    term = params[:term]
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

      send_data report.generate, :filename => "#{term}_#{configatron.statistic_report.monthly}", :type => 'application/pdf'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end	
  end
end
