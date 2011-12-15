class StatisticReportsController < ApplicationController
  require 'thinreports'
  before_filter :check_role

  def index
    @year = Time.zone.now.years_ago(1).strftime("%Y")
    @month = Time.zone.now.months_ago(1).strftime("%Y%m")
    @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
    @items_year = Time.zone.now.years_ago(1).strftime("%Y")
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
      @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    libraries = Library.all
    checkout_types = CheckoutType.all
    user_groups = UserGroup.all
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/monthly_report"

      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.now)       
      report.page.item(:term).value(term)

      # items all libraries
      data_type = 111
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.items'))
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # items each checkout_types
      checkout_types.each do |checkout_type|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(checkout_type.display_name.localize)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end 
        end
      end
      # missing items
      report.page.list(:list).add_row do |row|
        row.item(:library).value("(#{t('statistic_report.missing_items')})")
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          row.item(:library_line).show
        end  
      end
      # items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(checkout_type.display_name.localize)
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              end
              row.item("value#{t+1}").value(value)
              row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            end  
          end
        end
        # missing items
        report.page.list(:list).add_row do |row|
          row.item(:library).value("(#{t('statistic_report.missing_items')})")
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            row.item(:library_line).show
            line(row) if library == libraries.last
          end  
        end
      end

      # open days of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.opens')) if libraries.first == library
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 113, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 113, :library_id => library.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # checkout users each user type[adults, students, children]
      3.times do |i|
        data_type = 122
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.user_type_#{i+1}"))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => i+6).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => i+6).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show if i == 2
        end
      end
      # checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        # checkout users each user type[adults, students, children]
        3.times do |i|
          data_type = 122
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.user_type_#{i+1}"))
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => i+6).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => i+6).first.value rescue 0
              end
              row.item("value#{t+1}").value(value)
              sum = sum + value
            end  
            row.item("valueall").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end  
          end
        end
      end

      # daily average of checkout users all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.average_checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0, :option => 4).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0, :option => 4).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum/12)
        row.item(:library_line).show
      end
      # daily average of checkout users each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => library.id, :option => 4).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => library.id, :option => 4).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => i+1, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => i+1, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
      end
      # each user_group
      user_groups.each do |user_group|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(t('statistic_report.user_groups'))
          row.item(:option).value(user_group.display_name.localize)   
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :user_group_id => user_group.id).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :user_group_id => user_group.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show if user_group == user_groups.last
        end
      end

      # checkout items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => i+1, :age => nil).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => i+1, :age => nil).first.value rescue 0
              end
              row.item("value#{t+1}").value(value)
              sum = sum + value
            end  
            row.item("valueall").value(sum)
          end
        end
        user_groups.each do |user_group|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(t('statistic_report.user_groups'))
            row.item(:option).value(user_group.display_name.localize)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
              end
              row.item("value#{t+1}").value(value)
              sum = sum + value
            end  
            row.item("valueall").value(sum)
            if user_group == user_groups.last
	      row.item(:library_line).show
              line(row) if library == libraries.last
            end  
          end
        end
      end

      # daily average of checkout items all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.average_checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => 4).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => 4).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum/12)
	row.item(:library_line).show
      end
      # daily average of checkout items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => 4).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => 4).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
     
      # checkin items
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkin_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
	row.item(:library_line).show
      end
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # all users all libraries
      data_type = 112
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.users'))
        row.item(:library).value(t('statistic_report.all_library'))
        row.item(:option).value(t('statistic_report.all_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # users each user type[adults, students, children]
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.user_type_#{i+1}"))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => i+6).first.value rescue 0
            else	
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => i+6).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end
        end  
      end
      # unlocked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.unlocked_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 1).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 1).first.value rescue 0
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
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
        end  
      end
      # provisional users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.user_provisional'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
	  row.item(:library_line).show
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
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
        # users each user type[adults, students, children]
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.user_type_#{i+1}"))
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => i+6).first.value rescue 0 
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => i+6).first.value rescue 0 
              end
              row.item("value#{t+1}").value(value)
              row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            end
          end  
        end
        # unlocked users
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.unlocked_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 1).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 1).first.value rescue 0 
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
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
        end
        # provisional users all libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.user_provisional'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          end  
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.on_counter'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 1, :age => nil).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 1, :age => nil).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end
        row.item("valueall").value(sum)
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.from_opac'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 2, :age => nil).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 2, :age => nil).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end
      # reserves each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        # reserves on counter each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.on_counter'))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 1, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 1, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end
          row.item("valueall").value(sum)
        end
        # reserves from OPAC each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.from_opac'))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 2, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 2, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          sum = sum + value
        end  
        row.item("valueall").value(sum)
	row.item(:library_line).show
      end
      # questions each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
      # consultations of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.consultations')) if libraries.first == library
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => library.id).first.value rescue 0
            end
            logger.error "#{term}#{"%02d" % (t + 1)}"
            row.item("value#{t+1}").value(value)
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
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
    term = params[:term].strip
    unless term =~ /^\d{6}$/ && month_term?(term)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.years_ago(1).strftime("%Y")
      @month = term
      @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    libraries = Library.all
    logger.error "create daily statistic report: #{term}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/daily_report"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      [1,14,27].each do |start_date| # for 3 pages
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:year).value(term[0,4])
        report.page.item(:month).value(term[4,6])        
        # header
        if start_date != 27
          13.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}#{t('statistic_report.date')}")
          end
        else
          5.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}#{t('statistic_report.date')}")
          end
          report.page.list(:list).header.item("column#13").value(t('statistic_report.sum'))
        end
        # items all libraries
        data_type = 211
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.items'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
              row.item("value#13").value(value) if t == 4
            end
          end
          row.item(:library_line).show
        end
        # items each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
                row.item("value#13").value(value) if t== 4
              end
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
          end
        end
        # checkout users all libraries
        data_type = 222
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.checkout_users'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0)
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
        end
        # each user type[all_user, adults, students, children]
        3.times do |type|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => type+6).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => type+6).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :option => type+6)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show if type == 2
          end
        end
        # checkout users each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # each user type[all_user, adults, students, children]
          3.times do |type|
            report.page.list(:list).add_row do |row|
              row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => type+6).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
              else
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => type+6).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :option => type+6)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
              if type == 2
                row.item(:library_line).show
                line(row) if library == libraries.last
              end
            end
          end
        end

        # checkout items all libraries
        data_type = 221
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.checkout_items'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_conditionfirst.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0).no_condition
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => i+1).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => i+1).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :option => i+1)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
        end
        
        # checkout items each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          3.times do |i|
            report.page.list(:list).add_row do |row|
              row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => i+1).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
              else
                5.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => i+1).first.value rescue 0
                  row.item("value##{t+1}").value(value)
                end
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :option => i+1)
                datas.each do |data|
                  sum = sum + data.value
                end
                row.item("value#13").value(sum)
              end
              if i == 2
                row.item(:library_line).show
                line(row) if library == libraries.last
              end
            end
          end
        end
    
        # checkin items
        data_type = 251
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.checkin_items'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0).no_condition
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
          row.item(:library_line).show
        end
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
          end
        end

        # reserves all libraries
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.reserves'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else  
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => 0).no_condition
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
        end
        # reserves on counter all libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.on_counter'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 1).first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else  
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 1).first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => 0, :option => 1)
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
        end
        # reserves from OPAC all libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.from_opac'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
          else  
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => 0, :option => 2)
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
          row.item(:library_line).show
        end
        # reserves each library
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else  
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # on counter
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t('statistic_report.on_counter'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 1).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else  
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 1).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => library.id, :option => 1)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # from OPAC
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t('statistic_report.from_opac'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
            else  
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 233, :library_id => library.id, :option => 2)
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
          end
        end
        # questions all libraries
        report.page.list(:list).add_row do |row|
          row.item(:type).value(t('statistic_report.questions'))
          row.item(:library).value(t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end  
          else
            5.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(value)
            end
            sum = 0              
            datas = Statistic.where(:yyyymm => term, :data_type => 243, :library_id => 0).no_condition
            datas.each do |data|
              sum = sum + data.value 
            end
            row.item("value#13").value(sum)
          end
          row.item(:library_line).show
        end
        # questions each library
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end  
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 243, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
          end
        end
        # consultations each library
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:type).value(t('statistic_report.consultations')) if libraries.first == library
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 214, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end  
            else
              5.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 214, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(value)
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => 214, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
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

    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{6}$/ && end_at =~ /^\d{6}$/) && start_at.to_i <= end_at.to_i && month_term?(start_at) && month_term?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = start_at
      @t_end_at = end_at
      @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    libraries = Library.all
    logger.error "create daily timezone report: #{start_at} - #{end_at}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/timezone_report"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.now)
      report.page.item(:year).value(start_at[0,4])
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,6])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,6])
      report.page.item(:date_end_at).value(Time.parse("#{end_at}01").end_of_month.strftime("%d")) rescue nil 

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
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # each user type[all_user, adults, students, children]
      3.times do |type|
        data_type = 322
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
          sum = 0
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", data_type, type+6, 0, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)  
          row.item(:library_line).show if type == 2
        end
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
        # each user type[all_user, adults, students, children]
        3.times do |type|
          sum = 0
          data_type = 322
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
            hours.times do |t|
              value = 0
              datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", data_type, type+6, library.id, t+open])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value##{t+1}").value(value)
            end
            row.item("value#13").value(sum)
            if type == 2
              row.item(:library_line).show 
              line(row) if library == libraries.last
            end
          end
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
          sum = 0
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, 0, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)  
          row.item(:library_line).show if i == 2
        end
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
            sum = 0
            hours.times do |t|
              value = 0
              datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, library.id, t+open])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value##{t+1}").value(value)
            end
            row.item("value#13").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.on_counter'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.from_opac'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.on_counter'))
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.from_opac'))
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(value)
        end
        row.item("value#13").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(value)
          end
          row.item("value#13").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      send_data report.generate, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.timezone}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def get_day_report
    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{6}$/ && end_at =~ /^\d{6}$/) && start_at.to_i <= end_at.to_i && month_term?(start_at) && month_term?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_start_at = start_at
      @d_end_at = end_at
      @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    libraries = Library.all
    logger.error "create day statistic report: #{start_at} - #{end_at}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/day_report"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.now)
      report.page.item(:year).value(start_at[0,4])
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,6])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,6])
      report.page.item(:date_end_at).value(Time.parse("#{end_at}01").end_of_month.strftime("%d")) rescue nil 

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # each user type[all_user, adults, students, children]
      3.times do |type|
        data_type = 222
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
          sum = 0
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", data_type, type+6, 0, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)  
          row.item(:library_line).show if type == 2
        end
      end

      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        # each user type[all_user, adults, students, children]
        3.times do |type|
          sum = 0
          data_type = 222
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.user_type_#{type+1}"))
            7.times do |t|
              value = 0
              datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", data_type, type+6, library.id, t])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(value)
            end
            row.item("valueall").value(sum)
            if type == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
          sum = 0
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, 0, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)  
          row.item(:library_line).show if i == 2
        end
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
            sum = 0
            7.times do |t|
              value = 0
              datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, library.id, t])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(value)
            end
            row.item("valueall").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.on_counter'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.from_opac'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name.localize)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.on_counter'))
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.from_opac'))
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
     
 
      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # questions each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end


      send_data report.generate, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.day}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def get_age_report
    start_at = params[:start_at].strip
    end_at = params[:end_at].strip
    end_at = start_at if end_at.empty?
    unless (start_at =~ /^\d{6}$/ && end_at =~ /^\d{6}$/) && start_at.to_i <= end_at.to_i && month_term?(start_at) && month_term?(end_at)
      flash[:message] = t('statistic_report.invalid_month')
      @year = Time.zone.now.months_ago(1).strftime("%Y")
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_start_at = start_at
      @a_end_at = end_at
      @items_year = Time.zone.now.years_ago(1).strftime("%Y")
      render :index
      return false
    end
    libraries = Library.all
    logger.error "create day statistic report: #{start_at} - #{end_at}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/age_report"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.now)
      report.page.item(:year).value(start_at[0,4])
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,6])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,6])
      report.page.item(:date_end_at).value(Time.parse("#{end_at}01").end_of_month.strftime("%d")) rescue nil 

      # checkout users all libraries
      data_type = 122
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_users'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, 0])
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
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout items all libraries
      data_type = 121
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.checkout_items'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, 0])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)  
          row.item(:library_line).show
        end
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(t("statistic_report.item_type_#{i+1}"))
            sum = 0
            8.times do |t|
              value = 0
              datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, library.id])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(value)
            end
            row.item("valueall").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end  
        end
      end

      # all users all libraries
      data_type = 112
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.users'))
        row.item(:library).value(t('statistic_report.all_library'))
        row.item(:option).value(t('statistic_report.all_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end  
        row.item("valueall").value(sum)
      end
      # unlocked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.unlocked_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, t, 0])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end  
        row.item("valueall").value(sum)
      end
      # locked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.locked_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, t, 0])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end  
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end
      # users each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name.localize)
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end  
          row.item("valueall").value(sum)
        end
        # unlocked users each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.unlocked_users'))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end    
          row.item("valueall").value(sum)
        end
        # locked users each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.locked_users'))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # reserves all libraries
      data_type = 133
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.reserves'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.on_counter'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # reserves from OPAC all libraris
      report.page.list(:list).add_row do |row|
        row.item(:option).value(t('statistic_report.from_opac'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.on_counter'))
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('statistic_report.from_opac'))
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      data_type = 143
      report.page.list(:list).add_row do |row|
        row.item(:type).value(t('statistic_report.questions'))
        row.item(:library).value(t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(value)
        end
        row.item("valueall").value(sum)  
      end
      # questions each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymm >= #{start_at} AND yyyymm <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(value)
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      send_data report.generate, :filename => "#{start_at}_#{end_at}_#{configatron.statistic_report.age}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def get_items_report
    term = params[:term].strip
    unless term =~ /^\d{4}$/
      flash[:message] = t('statistic_report.invalid_year')
      @year = term
      @month = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @t_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @d_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_start_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @a_end_at = Time.zone.now.months_ago(1).strftime("%Y%m")
      @items_year = term
      render :index
      return false
    end
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/items_report"

      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.now)       
      report.page.item(:term).value(term)

      # items all libraries
      data_type = 111
      report.page.list(:list).add_row do |row|
        row.item(:library).value(t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          row.item("condition_line").show
        end  
      end
      # items each call_numbers
      call_numbers.each do |num|
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
          row.item(:option).value(num)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            row.item("condition_line").show if num == call_numbers.last
          end  
        end
      end
      # items each checkout_types
      checkout_types.each do |checkout_type|
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
          row.item(:option).value(checkout_type.display_name.localize)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            row.item("condition_line").show if checkout_type == checkout_types.last
          end  
        end
      end
      # missing items
      report.page.list(:list).add_row do |row|
        row.item(:condition).value(t('statistic_report.missing_items'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(value)
          row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
          line_for_items(row)
        end  
      end
      # items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            row.item("condition_line").show
          end  
        end
        # items each call_numbers
        call_numbers.each do |num|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
            row.item(:option).value(num)
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                datas = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num)
              else
                datas = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num)
              end
              value = 0
              datas.each do |data|
                value += data.value
              end
              row.item("value#{t+1}").value(value)
              row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
              row.item("condition_line").show if num == call_numbers.last
            end
          end
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              end
              row.item("value#{t+1}").value(value)
              row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
              row.item(:condition_line).show if checkout_type == checkout_types.last
            end
          end
        end
        # missing items
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(t('statistic_report.missing_items'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(value)
            row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
            row.item(:library_line).show
            row.item(:condition_line).show
          end  
        end
        # items each shelves and call_numbers
        library.shelves.each do |shelf|
          report.page.list(:list).add_row do |row|
            row.item(:library).value("(#{shelf.display_name})")
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                datas = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id)
              else
                datas = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id)
              end
              value = 0
              datas.each do |data|
                value += data.value
              end
              row.item("value#{t+1}").value(value)
              row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
              row.item("condition_line").show
            end
          end
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              12.times do |t|
                if t < 4 # for Japanese fiscal year
                  value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                else
                  value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                end
                row.item("value#{t+1}").value(value)
                row.item("valueall").value(value) if t == 2 # March(end of fiscal year)
                if num == call_numbers.last
                  row.item("condition_line").show
                  line_for_items(row) if shelf == library.shelves.last
                end
              end
            end
          end
        end
      end

      send_data report.generate, :filename => "#{term}_#{configatron.statistic_report.items}", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end

  end

private
  def line(row)
    row.item(:type_line).show
    row.item(:library_line).show
    row.item(:library_line).style(:border_color, '#000000')
    row.item(:library_line).style(:border_width, 1)
    row.item(:option_line).style(:border_color, '#000000')
    row.item(:option_line).style(:border_width, 1)
    row.item(:values_line).style(:border_color, '#000000')
    row.item(:values_line).style(:border_width, 1)
  end

  def line_for_items(row)
    row.item(:library_line).show
    row.item(:library_line).style(:border_color, '#000000')
    row.item(:library_line).style(:border_width, 1)
    row.item(:condition_line).show
    row.item(:condition_line).style(:border_color, '#000000')
    row.item(:condition_line).style(:border_width, 1)
    row.item(:option_line).style(:border_color, '#000000')
    row.item(:option_line).style(:border_width, 1)
    row.item(:values_line).style(:border_color, '#000000')
    row.item(:values_line).style(:border_width, 1)
  end

  def month_term?(term)
    begin 
      Time.parse("#{term}01")
      return true
    rescue ArgumentError
      return false
    end
  end
end
