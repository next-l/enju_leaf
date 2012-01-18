class StatisticReport < ActiveRecord::Base
  require 'thinreports'

  def self.get_monthly_report_pdf(term)
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
        row.item(:type).value(I18n.t('statistic_report.items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
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
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # Maarch(end of fiscal year)
          end 
          row.item(:library_line).show if checkout_type == checkout_types.last
        end
      end
=begin
      # missing items
      report.page.list(:list).add_row do |row|
        row.item(:library).value("(#{t('statistic_report.missing_items')})")
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          row.item(:library_line).show
        end  
      end
=end
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
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
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
              row.item("value#{t+1}").value(to_format(value))
              row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
            end  
            if checkout_type == checkout_types.last
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
=begin
        # missing items
        report.page.list(:list).add_row do |row|
          row.item(:library).value("(#{t('statistic_report.missing_items')})")
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
            row.item(:library_line).show
            line(row) if library == libraries.last
          end  
        end
=end
      end

      # open days of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:type).value(I18n.t('statistic_report.opens')) if libraries.first == library
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 113, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 113, :library_id => library.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # checkout users each user type
      5.downto(1) do |i|
        data_type = 122
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.user_type_#{i}"))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 0, user_type => i).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 0, user_type => i).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show if i == 1
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        # checkout users each user type
        5.downto(1) do |i|
          data_type = 122
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.user_type_#{i}"))
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 0, user_type => i).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 0, user_type => i).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum = sum + value
            end  
            row.item("valueall").value(sum)
            if i == 1
              row.item(:library_line).show
              line(row) if library == libraries.last
            end  
          end
        end
      end

      # daily average of checkout users all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.average_checkout_users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0, :option => 4).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 122, :library_id => 0, :option => 4).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => i+1, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => i+1, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show if i == 2
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => i+1, :age => nil).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id, :option => i+1, :age => nil).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum = sum + value
            end  
            row.item("valueall").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last if library == libraries.last
            end
          end
        end
      end
      # checkout items each user_group
      user_groups.each do |user_group|
        report.page.list(:list).add_row do |row|
          if user_group == user_groups.first
            row.item(:type).value(I18n.t('statistic_report.checkout_items_each_user_groups'))
            row.item(:library).value(I18n.t('statistic_report.all_library')) 
          end
          row.item(:option).value(user_group.display_name.localize)   
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :user_group_id => user_group.id).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :user_group_id => user_group.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show if user_group == user_groups.last
        end
      end
      libraries.each do |library|
        user_groups.each do |user_group|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name.localize) if user_group == user_groups.first
            row.item(:option).value(user_group.display_name.localize)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
              end
              row.item("value#{t+1}").value(to_format(value))
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
        row.item(:type).value(I18n.t('statistic_report.average_checkout_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => 4).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 121, :library_id => 0, :option => 4).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
     
      # checkin items
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkin_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # daily average of checkin items all library
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.average_checkin_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0, :option => 4).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => 0, :option => 4).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum = sum + value
        end  
        row.item("valueall").value(sum/12)
	row.item(:library_line).show
      end
      # daily average of checkin items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => library.id, :option => 4).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 151, :library_id => library.id, :option => 4).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum/12)
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # all users all libraries
      data_type = 112
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        row.item(:option).value(I18n.t('statistic_report.all_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
        end  
      end
      # users each user type
      5.downto(1) do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.user_type_#{i}"))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 0, :user_type => i).first.value rescue 0
            else	
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 0, :user_type => i).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          end
        end  
      end
      # unlocked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.unlocked_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 1).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 1).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
        end  
      end
      # locked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.locked_users'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
        end  
      end
      # provisional users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.user_provisional'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
	  row.item(:library_line).show
        end  
      end

      # users each library
      libraries.each do |library|
        # all users
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          row.item(:option).value(I18n.t('statistic_report.all_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          end  
        end
        # users each user type
        5.downto(1) do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.user_type_#{i}"))
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 0, :user_type => i).first.value rescue 0 
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 0, :user_type => i).first.value rescue 0 
              end
              row.item("value#{t+1}").value(to_format(value))
              row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
            end
          end  
        end
        # unlocked users
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.unlocked_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 1).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 1).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          end  
        end
        # locked users
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.locked_users'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          end  
        end
        # provisional users all libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.user_provisional'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          end  
	  row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.reserves'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum = sum + value
        end  
        row.item("valueall").value(sum)
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.on_counter'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 1, :age => nil).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 1, :age => nil).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum = sum + value
        end
        row.item("valueall").value(sum)
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.from_opac'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 2, :age => nil).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => 0, :option => 2, :age => nil).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
        end
        # reserves on counter each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.on_counter'))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 1, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 1, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end
          row.item("valueall").value(sum)
        end
        # reserves from OPAC each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.from_opac'))
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 2, :age => nil).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 133, :library_id => library.id, :option => 2, :age => nil).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.questions'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 143, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
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
            row.item("value#{t+1}").value(to_format(value))
            sum = sum + value
          end  
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
      # visiters all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.visiters'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 116, :library_id => 0).first.value rescue 0 
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 116, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum += value
        end
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end
      # visiters of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 116, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 116, :library_id => library.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
      # consultations all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.consultations'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => 0).first.value rescue 0 
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum += value
        end
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end
      # consultations of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 114, :library_id => library.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
      # copies all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.copies'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 115, :library_id => 0).first.value rescue 0 
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 115, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum += value
        end
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end

      # copies of each libraries
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => 115, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => 115, :library_id => library.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      logger.error $@.join('\n')
      return false
    end	
  end

  def self.get_monthly_report_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_monthly_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:option, 'statistic_report.option']
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    user_groups = UserGroup.all
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      9.times do |t|
        row << I18n.t('statistic_report.month', :num => t+4)
        columns << ["#{term}#{"%02d" % (t + 4)}"]
      end
      3.times do |t|
        row << I18n.t('statistic_report.month', :num => t+1)
        columns << ["#{term.to_i + 1}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"

      # items all libraries
      data_type = 111
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        end
      end  
      output.print '"'+row.join('","')+"\"\n"
      # items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          end
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # items each library
      libraries.each do |library|
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          end
        end
        output.print '"'+row.join('","')+"\"\n"
        # items each checkout_types
        checkout_types.each do |checkout_type|
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.items')
            when :library
              row << library.display_name
            when :option
              row << checkout_type.display_name.localize
            when "sum"
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # open days of each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.opens')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 113, :library_id => library.id).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout users all libraries
      data_type = 122
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # checkout users each user type
      5.downto(1) do |i|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.user_type_#{i}")
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :option => 0, user_type => i).first.value rescue 0
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout users each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # checkout users each user type
        5.downto(1) do |i|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_users')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.user_type_#{i}")
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :option => 0, user_type => i).first.value rescue 0
              sum += value
              row << to_format(value)
            end  
          end
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # daily average of checkout users all library
      data_type = 122
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.average_checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum/12)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :option => 4).first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # daily average of checkout users each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.average_checkout_users')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum/12)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :option => 4).first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout items all libraries
      data_type = 121
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # checkout items all libraries each item types
      3.times do |i|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.item_type_#{i+1}")
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :option => i+1, :age => nil).first.value rescue 0
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout items each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 121, :library_id => library.id).no_condition.first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        3.times do |i|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.item_type_#{i+1}")
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :option => i+1, :age => nil).first.value rescue 0
              sum += value
              row << to_format(value)
            end  
          end
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # checkout items each user_group
      user_groups.each do |user_group|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items_each_user_groups')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << user_group.display_name.localize
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :user_group_id => user_group.id).first.value rescue 0
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      libraries.each do |library|
        user_groups.each do |user_group|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items_each_user_groups')
            when :library
              row << library.display_name.localize
            when :option
              row << user_group.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
              sum += value
              row << to_format(value)
            end  
          end
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # daily average of checkout items all library
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.average_checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum/12) rescue 0
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 121, :library_id => 0, :option => 4).first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # daily average of checkout items each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.average_checkout_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum/12)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 121, :library_id => library.id, :option => 4).first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
     
      # checkin items
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkin_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 151, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkin_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 151, :library_id => library.id).no_condition.first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # daily average of checkin items all library
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.average_checkin_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum/12)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 151, :library_id => 0, :option => 4).first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # daily average of checkin items each library
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.average_checkin_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << ""
          when "sum"
            row << to_format(sum/12)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 151, :library_id => library.id, :option => 4).first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # all users all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.all_users')
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # users each user type
      5.downto(1) do |i|
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.user_type_#{i}")
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => 0, :option => 0, :user_type => i).first.value rescue 0
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => 0, :option => 0, :user_type => i).first.value rescue 0
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # unlocked users all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.unlocked_users')
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => 0, :option => 1).first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => 0, :option => 1).first.value rescue 0
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # locked users all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.locked_users')
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => 0, :option => 2).first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => 0, :option => 2).first.value rescue 0
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # provisional users all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.user_provisional')
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => 0, :option => 3).first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => 0, :option => 3).first.value rescue 0
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # users each library
      libraries.each do |library|
        # all users
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t('statistic_report.user_provisional')
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # users each user type
        5.downto(1) do |i|
          row = []
          columns.each do |column|
           case column[0]
            when :type
              row << I18n.t('statistic_report.users')  
            when :library
              row << I18n.t('statistic_report.all_library')
            when :option
              row << I18n.t("statistic_report.user_type_#{i}")
            when "sum"
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => library.id, :option => 0, :user_type => i).first.value rescue 0 
              row << to_format(value)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => library.id, :option => 0, :user_type => i).first.value rescue 0 
              row << to_format(value)
            end  
          end
          output.print '"'+row.join('","')+"\"\n"
        end
        # unlocked users
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t('statistic_report.unlocked_users')
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => library.id, :option => 1).first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => library.id, :option => 1).first.value rescue 0 
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # locked users
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t('statistic_report.locked_users')
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => library.id, :option => 2).first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => library.id, :option => 2).first.value rescue 0 
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # provisional users all libraries
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t('statistic_report.user_provisional')
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 112, :library_id => library.id, :option => 3).first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 112, :library_id => library.id, :option => 3).first.value rescue 0 
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end

      # reserves all libraries
      sum = 0
      row = []
      columns.each do |column|
       case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')  
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # reserves on counter all libraries
      sum = 0
      row = []
      columns.each do |column|
       case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')  
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.on_counter')
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => 0, :option => 1, :age => nil).first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # reserves from OPAC all libraries
      sum = 0
      row = []
      columns.each do |column|
       case column[0]
        when :type
          row << I18n.t('statistic_report.users')  
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.from_opac')
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => 0, :option => 2, :age => nil).first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # reserves each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => library.id).no_condition.first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # reserves on counter each libraries
        sum = 0
        row = []
        columns.each do |column|
         case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.on_counter')
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => library.id, :option => 1, :age => nil).first.value rescue 0
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
        # reserves from OPAC each libraries
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')  
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.from_opac')
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 133, :library_id => library.id, :option => 2, :age => nil).first.value rescue 0
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # questions all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.questions')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 143, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # questions each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.questions')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 143, :library_id => library.id).no_condition.first.value rescue 0 
            sum += value
            row << to_format(value)
          end
        end  
        output.print '"'+row.join('","')+"\"\n"
      end
      # visiters all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.visiters')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 116, :library_id => 0).first.value rescue 0 
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # visiters of each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.visiters')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 116, :library_id => library.id).first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # consultations all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.consultations')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 114, :library_id => 0).first.value rescue 0 
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # consultations of each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.consultations')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 114, :library_id => library.id).first.value rescue 0 
            sum = value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
      # copies all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.copies')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 115, :library_id => 0).first.value rescue 0 
          sum += value
          row << to_format(value)
        end  
      end
      output.print '"'+row.join('","')+"\"\n"
      # copies of each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.copies')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 115, :library_id => library.id).first.value rescue 0 
            sum += value
            row << to_format(value)
          end  
        end
        output.print '"'+row.join('","')+"\"\n"
      end
    end
    return csv_file
  end

  def self.get_daily_report_pdf(term)
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

      num_for_last_page = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i - 26
      [1,14,27].each do |start_date| # for 3 pages
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:year).value(term[0,4])
        report.page.item(:month).value(term[4,6])        
        # header
        if start_date != 27
          13.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
          end
        else
          num_for_last_page.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
          end
          report.page.list(:list).header.item("column#13").value(I18n.t('statistic_report.sum'))
        end
        # items all libraries
        data_type = 211
        report.page.list(:list).add_row do |row|
          row.item(:type).value(I18n.t('statistic_report.items'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
              row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
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
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
              end
            end
            row.item(:library_line).show
            line(row) if library == libraries.last
          end
        end
        # checkout users all libraries
        data_type = 222
        report.page.list(:list).add_row do |row|
          row.item(:type).value(I18n.t('statistic_report.checkout_users'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
            sum = 0
            datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0).no_condition
            datas.each do |data|
              sum = sum + data.value
            end
            row.item("value#13").value(sum)
          end
        end
        # each user type
        5.downto(1) do |type|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 0, :user_type => type).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 0, :user_type => type).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
              sum = 0
              datas = Statistic.where(["yyyymm = ? AND data_type = ? AND library_id = ? AND option = 0 AND user_type = ? ", term, data_type, 0, type])
              datas.each do |data|
                sum += data.value                               
              end
              row.item("value#13").value(sum)
            end
            row.item(:library_line).show if type == 1
          end
        end
        # checkout users each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
              sum = 0
              datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id).no_condition
              datas.each do |data|
                sum = sum + data.value
              end
              row.item("value#13").value(sum)
            end
          end
          # each user type
          5.downto(1) do |type|
            report.page.list(:list).add_row do |row|
              row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option =>0, :user_type => type).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => 0, user_type => type).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
                sum = 0
                datas = Statistic.where(["yyyymm = ? AND data_type = ? AND library_id = ? AND option = 0 AND user_type = ?", term, data_type, library.id, type])
                datas.each do |data|
                  sum += data.value                               
                end
                row.item("value#13").value(sum)
              end
              if type == 1
                row.item(:library_line).show
                line(row) if library == libraries.last
              end
            end
          end
        end

        # checkout items all libraries
        data_type = 221
        report.page.list(:list).add_row do |row|
          row.item(:type).value(I18n.t('statistic_report.checkout_items'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_conditionfirst.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
            row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => i+1).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => i+1).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
              row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => i+1).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => i+1).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
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
          row.item(:type).value(I18n.t('statistic_report.checkin_items'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
          row.item(:type).value(I18n.t('statistic_report.reserves'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else  
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
          row.item(:option).value(I18n.t('statistic_report.on_counter'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 1).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else  
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 1).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
          row.item(:option).value(I18n.t('statistic_report.from_opac'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else  
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
                row.item("value##{t+1}").value(to_format(value))
              end
            else  
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
            row.item(:option).value(I18n.t('statistic_report.on_counter'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 1).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else  
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 1).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
            row.item(:option).value(I18n.t('statistic_report.from_opac'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else  
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 233, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
          row.item(:type).value(I18n.t('statistic_report.questions'))
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end  
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
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
                row.item("value##{t+1}").value(to_format(value))
              end  
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 243, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
            row.item(:type).value(I18n.t('statistic_report.consultations')) if libraries.first == library
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 214, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end  
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => 214, :library_id => library.id).no_condition.first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
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
      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_daily_report_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_daily_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    libraries = Library.all
    days = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:option, 'statistic_report.option']
    ]
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      days.times do |t|
        row << I18n.t('statistic_report.date', :num => t+1)
        columns << ["#{term}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"

      # items all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          value = Statistic.where(:yyyymmdd => "#{term}#{days}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        end
      end  
      output.print '"'+row.join('","')+"\"\n"
      # items each libraries
      libraries.each do |library|
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymmdd => "#{term}#{days}", :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0
            row << to_format(value)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0
            row << to_format(value)
          end
        end  
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 222, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end  
      output.print '"'+row.join('","')+"\"\n"
      # each user type
      5.downto(1) do |type|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.user_type_#{type}")
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 222, :library_id => 0, :option => 0, :user_type => type).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end  
        output.print '"'+row.join('","')+"\"\n"
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 222, :library_id => library.id).no_condition.first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end  
        output.print '"'+row.join('","')+"\"\n"
        # each user type
        5.downto(1) do |type|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_users')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.user_type_#{type}")
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => 222, :library_id => library.id, :option =>0, :user_type => type).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end  
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # checkout items all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 221, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end
      output.print '"'+row.join('","')+"\"\n"  
      3.times do |i|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.item_type_#{i+1}")
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 221, :library_id => 0, :option => i+1).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
      end        
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 221, :library_id => library.id).no_condition.first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
        3.times do |i|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.item_type_#{i+1}")
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => 221, :library_id => library.id, :option => i+1).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end 
          output.print '"'+row.join('","')+"\"\n"
        end
      end
      # checkin items
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkin_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 251, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end 
      output.print '"'+row.join('","')+"\"\n"
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkin_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 251, :library_id => library.id).no_condition.first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
      end
      # reserves all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end 
      output.print '"'+row.join('","')+"\"\n"
      # reserves on counter all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.on_counter')
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => 0, :option => 1).first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end 
      output.print '"'+row.join('","')+"\"\n"
      # reserves from OPAC all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.from_opac')
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => 0, :option => 2).first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end 
      output.print '"'+row.join('","')+"\"\n"
      # reserves each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => library.id).no_condition.first.value rescue 0
	    sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
        # on counter
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.on_counter')
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => library.id, :option => 1).first.value rescue 0
	    sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
        # from OPAC
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.from_opac')
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 233, :library_id => library.id, :option => 2).first.value rescue 0
	    sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
      end
      # questions all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.questions')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 243, :library_id => 0).no_condition.first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end 
      output.print '"'+row.join('","')+"\"\n"
      # questions each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.questions')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 243, :library_id => library.id).no_condition.first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
      end
      # consultations each library
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.consultations')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 214, :library_id => library.id).no_condition.first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end 
        output.print '"'+row.join('","')+"\"\n"
      end
    end
    return csv_file
  end

  def self.get_timezone_report_pdf(start_at, end_at)
    #default setting 9 - 20
    open = configatron.statistic_report.open
    hours = configatron.statistic_report.hours

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
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,2])
      report.page.item(:date_start_at).value(start_at[6,2])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,2])
      report.page.item(:date_end_at).value(end_at[6,2]) rescue nil 

      # header 
      hours.times do |t|
        report.page.list(:list).header.item("column##{t+1}").value("#{t+open}#{I18n.t('statistic_report.hour')}")
      end
      report.page.list(:list).header.item("column#15").value(I18n.t('statistic_report.sum'))

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
      end
      # each user type
      5.downto(1) do |type|
        data_type = 322
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
          sum = 0
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND hour = ?", data_type, 0, type, 0, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)  
          row.item(:library_line).show if type == 1
        end
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
        end
        # each user type
        5.downto(1) do |type|
          sum = 0
          data_type = 322
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
            hours.times do |t|
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND hour = ?", data_type, 0, type, library.id, t+open])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value##{t+1}").value(to_format(value))
            end
            row.item("value#15").value(sum)
            if type == 1
              row.item(:library_line).show 
              line(row) if library == libraries.last
            end
          end
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
          sum = 0
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, 0, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)  
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
            sum = 0
            hours.times do |t|
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, library.id, t+open])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value##{t+1}").value(to_format(value))
            end
            row.item("value#15").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
      end

      # reserves all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.reserves'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.on_counter'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.from_opac'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", 0, t+open])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.on_counter'))
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.from_opac'))
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", library.id, t+open])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.questions'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        hours.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", 0, t+open]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value##{t+1}").value(to_format(value))
        end
        row.item("value#15").value(sum)  
        row.item(:library_line).show
      end
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          hours.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", library.id, t+open]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value##{t+1}").value(to_format(value))
          end
          row.item("value#15").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_timezone_report_csv(start_at, end_at)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{start_at}_#{end_at}_timezone_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:option, 'statistic_report.option']
    ]
    #default setting 9 - 20
    open = configatron.statistic_report.open
    hours = configatron.statistic_report.hours

    libraries = Library.all
    logger.error "create daily timezone report: #{start_at} - #{end_at}"
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      hours.times do |t|
        row << "#{t+open}#{I18n.t('statistic_report.hour')}"
        columns << [t+open]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      # checkout users all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # each user type
      5.downto(1) do |type|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.user_type_#{type}")
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND hour = ?", 322, 0, type, 0, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout users each libraries
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 322 AND library_id = ? AND hour = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # each user type
        5.downto(1) do |type|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_users')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.user_type_#{type}")
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND hour = ?", 322, 0, type, library.id, column[0]])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # checkout items all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      3.times do |i|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.item_type_#{i+1}")
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, 0, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout items each libraries
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 321 AND library_id = ? AND hour = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        3.times do |i|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items')
            when :library
              row << library.display_name
            when :option
              row << I18n.t("statistic_report.item_type_#{i+1}")
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND hour = ?", 321, i+1, library.id, column[0]])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end

      # reserves all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves on counter all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.on_counter')
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", 0, column[0]])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves from OPAC all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.from_opac')
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", 0, column[0]])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves each libraries
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ?", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # on counter
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name
          when :option
            row << I18n.t('statistic_report.on_counter')
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 1 AND age IS NULL", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # from OPAC
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name
          when :option
            row << I18n.t('statistic_report.from_opac')
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 333 AND library_id = ? AND hour = ? AND option = 2 AND age IS NULL", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end

      # questions all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.questions')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves each libraries
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.questions')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 343 AND library_id = ? AND hour = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
    end
    return csv_file
  end

  def self.get_day_report_pdf(start_at, end_at)
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
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,2])
      report.page.item(:date_start_at).value(start_at[6,2])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,2])
      report.page.item(:date_end_at).value(end_at[6,2])

      # checkout users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        row.item("valueall").value(sum)  
      end
      # each user type
      5.downto(1) do |type|
        data_type = 222
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
          sum = 0
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND day = ?", data_type, 0, type, 0, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)  
          row.item(:library_line).show if type == 1
        end
      end

      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
        end
        # each user type
        5.downto(1) do |type|
          sum = 0
          data_type = 222
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.user_type_#{type}"))
            7.times do |t|
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND day = ?", data_type, 0, type, library.id, t])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(to_format(value))
            end
            row.item("valueall").value(sum)
            if type == 1
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end
        end
      end

      # checkout items all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        row.item("valueall").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
          sum = 0
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, 0, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
            sum = 0
            7.times do |t|
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, library.id, t])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(to_format(value))
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
        row.item(:type).value(I18n.t('statistic_report.reserves'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        row.item("valueall").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.on_counter'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        row.item("valueall").value(sum)  
      end
      # reserves from OPAC all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.from_opac'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.on_counter'))
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.from_opac'))
          7.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", library.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end
     
 
      # questions all libraries
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.questions'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        7.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", 0, t]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", library.id, t]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_day_report_csv(start_at, end_at)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{start_at}_#{end_at}_day_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:option, 'statistic_report.option']
    ]
    libraries = Library.all
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      7.times do |t|
        row << I18n.t("statistic_report.day_#{t}")
        columns << [t]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      # checkout users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # each user type
      5.downto(1) do |type|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.user_type_#{type}")
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND day = ?", 222, 0, type, 0, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 222 AND library_id = ? AND day = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # each user type
        5.downto(1) do |type|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_users')
            when :library
              row << library.display_name.localize
            when :option
              row << ""
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND user_type = ? AND library_id = ? AND day = ?", 222, 0, type, library.id, column[0]])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # checkout items all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      3.times do |i|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :option
            row << I18n.t("statistic_report.item_type_#{i+1}")
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, 0, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 221 AND library_id = ? AND day = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        3.times do |i|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items')
            when :library
              row << library.display_name.localize
            when :option
              row << I18n.t("statistic_report.item_type_#{i+1}")
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND library_id = ? AND day = ?", 221, i+1, library.id, column[0]])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # reserves all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves on counter all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.on_counter')
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves from OPAC all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << I18n.t('statistic_report.from_opac')
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ?", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # on counter
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.on_counter')
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 1", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # from OPAC
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :option
            row << I18n.t('statistic_report.from_opac')
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 233 AND library_id = ? AND day = ? AND option = 2", library.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end 
      # questions all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.questions')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", 0, column[0]]).no_condition
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # questions each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.questions')
          when :library
            row << library.display_name.localize
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = 243 AND library_id = ? AND day = ?", library.id, column[0]]).no_condition
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
    end
    return csv_file
  end

  def self.get_age_report_pdf(start_at, end_at)
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
      report.page.item(:year_start_at).value(start_at[0,4])
      report.page.item(:month_start_at).value(start_at[4,2])
      report.page.item(:date_start_at).value(start_at[6,2])
      report.page.item(:year_end_at).value(end_at[0,4])
      report.page.item(:month_end_at).value(end_at[4,2])
      report.page.item(:date_end_at).value(end_at[6,2])

      # checkout users all libraries
      data_type = 222
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
        row.item("valueall").value(sum)  
        row.item(:library_line).show
      end
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # checkout items all libraries
      data_type = 221
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.checkout_items'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
        row.item("valueall").value(sum)  
      end
      3.times do |i|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", data_type, t, 0, i+1])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", data_type, 10, 0, i+1])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))  
          row.item("valueall").value(sum)  
          row.item(:library_line).show if i == 2
        end
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        3.times do |i|
          report.page.list(:list).add_row do |row|
            row.item(:option).value(I18n.t("statistic_report.item_type_#{i+1}"))
            sum = 0
            8.times do |t|
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", data_type, t, library.id, i+1])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row.item("value#{t}").value(to_format(value))
            end
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", data_type, 10, library.id, i+1])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value8").value(to_format(value))
            row.item("valueall").value(sum)
            if i == 2
              row.item(:library_line).show
              line(row) if library == libraries.last
            end
          end  
        end
      end

      # all users all libraries
      data_type = 212
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.users'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        row.item(:option).value(I18n.t('statistic_report.all_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end  
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
        row.item("valueall").value(sum)
      end
      # unlocked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.unlocked_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, t, 0])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end  
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, 10, 0])
        datas.each do |data|
          value =value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
        row.item("valueall").value(sum)
      end
      # locked users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.locked_users'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, t, 0])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end  
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, 10, 0])
        datas.each do |data|
          value =value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
        row.item("valueall").value(sum)
      end
      # provisional users all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.user_provisional'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 3, t, 0])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end  
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 3, 10, 0])
        datas.each do |data|
          value =value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end  
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 0, 10, library.id])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        # unlocked users each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.unlocked_users'))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end    
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 1, 10, library.id])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        # locked users each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.locked_users'))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end  
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 2, 10, library.id])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        # provisional users each libraries
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.user_provisional'))
          sum = 0
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 3, t, library.id])
            datas.each do |data|
              value =value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end  
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", data_type, 3, 10, library.id])
          datas.each do |data|
            value =value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # user_areas all libraries
      data_type = 262
      # all_area
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.user_areas'))
        row.item(:library).value(I18n.t('statistic_report.all_areas'))
        sum = 0
        8.times do |t|
          value = 0
          #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ?", data_type, t])
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ?", end_at, data_type, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ?", data_type, 10])
        datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ?", end_at, data_type, 10])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
        row.item("valueall").value(sum)
        row.item(:library_line).show
      end
      # each_area
      @areas = Area.all
      @areas.each do |a|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(a.name)
          sum = 0
          8.times do |t|
            value = 0
            #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND area_id = ? AND age = ?", data_type, a.id, t])
            datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND area_id = ? AND age = ?", end_at, data_type, a.id, t])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND area_id = ? AND age = ?", data_type, a.id, 10])
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND area_id = ? AND age = ?", end_at, data_type, a.id, 10])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))

          row.item("valueall").value(sum)
          row.item(:library_line).show
        end
      end
      # unknown area
      report.page.list(:list).add_row do |row|
        row.item(:library).value(I18n.t('statistic_report.other_area'))
        sum = 0
        8.times do |t|
          value = 0
          #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ?", data_type, t])
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ? AND area_id = 0", end_at, data_type, t])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        #datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ?", data_type, 10])
        datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ? AND area_id = 0", end_at, data_type, 10])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))
        row.item("valueall").value(sum)
        line(row)
      end

      # reserves all libraries
      data_type = 233
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.reserves'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
        row.item("valueall").value(sum)  
      end
      # reserves on counter all libraries
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.on_counter'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
        row.item("valueall").value(sum)  
      end
      # reserves from OPAC all libraris
      report.page.list(:list).add_row do |row|
        row.item(:option).value(I18n.t('statistic_report.from_opac'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
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
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        # on counter
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.on_counter'))
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
        end
        # from OPAC
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:option).value(I18n.t('statistic_report.from_opac'))
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      # questions all libraries
      data_type = 243
      report.page.list(:list).add_row do |row|
        row.item(:type).value(I18n.t('statistic_report.questions'))
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        8.times do |t|
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value#{t}").value(to_format(value))
        end
        value = 0
        datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, 10, 0])
        datas.each do |data|
          value = value + data.value
        end
        sum = sum + value
        row.item("value8").value(to_format(value))  
        row.item("valueall").value(sum)  
        row.item(:library_line).show
      end
      # questions each libraries
      libraries.each do |library|
        sum = 0
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          8.times do |t|
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, t, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row.item("value#{t}").value(to_format(value))
          end
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", data_type, 10, library.id])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row.item("value8").value(to_format(value))
          row.item("valueall").value(sum)
          row.item(:library_line).show
          line(row) if library == libraries.last
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_age_report_csv(start_at, end_at)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{start_at}_#{end_at}_day_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:area, 'activerecord.models.area'],
      [:option, 'statistic_report.option']
    ]
    libraries = Library.all
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      8.times do |t|
        if t == 0
          row << "#{t} ~ 9"
        elsif t < 7
          row << "#{t}0 ~ #{t}9"
        else
          row << "#{t}0 ~ "
        end
        columns << [t]
      end
      row << I18n.t('page.unknown')
      columns << ["unknown"]
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      # checkout users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << ""
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", 222, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", 222, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # checkout users each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_users')
          when :library
            row << library.display_name
          when :area
            row << ""
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", 222, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ?", 222, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout items all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.checkout_items')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << ""
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", 221, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", 221, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      3.times do |i|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :area
            row << ""
          when :option
            row << I18n.t("statistic_report.item_type_#{i+1}")
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", 221, 10, 0, i+1])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", 221, column[0], 0, i+1])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # checkout items each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.checkout_items')
          when :library
            row << library.display_name
          when :area
            row << ""
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", 221, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = 0", 221, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        3.times do |i|
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.checkout_items')
            when :library
              row << library.display_name
            when :area
              row << ""
            when :option
              row << I18n.t("statistic_report.item_type_#{i+1}")
            when "unknown"
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", 221, 10, library.id, i+1])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND age = ? AND library_id = ? AND option = ?", 221, column[0], library.id, i+1])
              datas.each do |data|
                value = value + data.value
              end
              sum = sum + value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # all users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.all_users')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 0, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 0, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # unlocked users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.unlocked_users')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 1, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 1, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # locked users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.locked_users')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 2, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 2, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # provisional users all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.users')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.user_provisional')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 3, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 3, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # users each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 0, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 0, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # unlocked users each libraries
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << I18n.t('statistic_report.unlocked_users')
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 1, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 1, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # locked users each libraries
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << I18n.t('statistic_report.locked_users')
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 2, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 2, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # provisional users each libraries
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.users')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << I18n.t('statistic_report.user_provisional')
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 3, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = ? AND age = ? AND library_id = ?", 212, 3, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # user_areas all libraries
      # all_area
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.user_areas')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << I18n.t('statistic_report.all_areas')
        when :option
          row << ""
        when "unknown"
          value = 0
        datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ?", end_at, 262, 10])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ?", end_at, 262, column[0]])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # each_area
      @areas = Area.all
      @areas.each do |a|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.user_areas')
          when :library
            row << ""
          when :area
            row << a.name
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND area_id = ? AND age = ?", end_at, 262, a.id, 10])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND area_id = ? AND age = ?", end_at, 262, a.id, column[0]])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # unknown area
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.user_areas')
        when :library
          row << ""
        when :area
          row << I18n.t('statistic_report.other_area')
        when :option
          row << ""
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ? AND area_id = 0", end_at, 262, 10])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd = ? AND data_type = ? AND age = ? AND area_id = 0", end_at, 262, column[0]])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << ""
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 233, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 233, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves on counter all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.on_counter')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", 233, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", 233, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves from OPAC all libraris
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.reserves')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << I18n.t('statistic_report.from_opac')
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", 233, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", 233, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # reserves each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 233, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 233, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # on counter
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << I18n.t('statistic_report.on_counter')
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", 233, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 1 AND age = ? AND library_id = ?", 233, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # from OPAC
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.reserves')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << I18n.t('statistic_report.from_opac')
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", 233, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 2 AND age = ? AND library_id = ?", 233, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # questions all libraries
      sum = 0
      row = []
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.questions')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :area
          row << ""
        when :option
          row << ""
        when "unknown"
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 243, 10, 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        when "sum"
          row << to_format(sum)
        else
          value = 0
          datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 243, column[0], 0])
          datas.each do |data|
            value = value + data.value
          end
          sum = sum + value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # questions each libraries
      libraries.each do |library|
        sum = 0
        row = []
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.questions')
          when :library
            row << library.display_name.localize
          when :area
            row << ""
          when :option
            row << ""
          when "unknown"
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 243, 10, library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          when "sum"
            row << to_format(sum)
          else
            value = 0
            datas = Statistic.where(["yyyymmdd >= #{start_at} AND yyyymmdd <= #{end_at} AND data_type = ? AND option = 0 AND age = ? AND library_id = ?", 243, column[0], library.id])
            datas.each do |data|
              value = value + data.value
            end
            sum = sum + value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
    end
    return csv_file
  end

  def self.get_items_daily_pdf(term)
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/items_daily"

      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      num_for_last_page = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i - 26
      [1,14,27].each do |start_date| # for 3 pages
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:year).value(term[0,4])
        report.page.item(:month).value(term[4,6])        
        # header
        if start_date != 27
          13.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
          end
        else
          num_for_last_page.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => start_date))
          end
          report.page.list(:list).header.item("column#13").value(I18n.t('statistic_report.sum'))
        end
        # items all libraries
        data_type = 211
        report.page.list(:list).add_row do |row|
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
              row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
            end
          end
          row.item("condition_line").show
        end  
        # items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
                end
              end
              row.item("condition_line").show if num == call_numbers.last
            end  
          end
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
              end
            end
            row.item("condition_line").show if checkout_type == checkout_types.last
          end  
        end
        # missing items
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(I18n.t('statistic_report.missing_items'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
              row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
            end
          end
          line_for_items(row)
        end  
        # items each library
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).no_condition.first.value rescue 0 
                row.item("value##{t+1}").value(to_format(value))
              end 
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
              end
            end
            row.item("condition_line").show
          end  
          # items each call_numbers
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                if start_date != 27
                  13.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                  end
                else
                  num_for_last_page.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                    row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
                  end
                end
                row.item("condition_line").show if num == call_numbers.last
              end
            end
          end
          # items each checkout_types
          checkout_types.each do |checkout_type|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
              row.item(:option).value(checkout_type.display_name.localize)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
                end
              end
              row.item(:condition_line).show if checkout_type == checkout_types.last
            end
          end
          # missing items
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('statistic_report.missing_items'))
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymm => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
              end
            end
            row.item(:library_line).show
            row.item(:condition_line).show
          end  
          # items each shelves and call_numbers
          library.shelves.each do |shelf|
            report.page.list(:list).add_row do |row|
              row.item(:library).value("(#{shelf.display_name})")
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
                end
              end
              row.item("condition_line").show
              line_for_items(row) if call_numbers.nil?
            end
            unless call_numbers.nil?
              call_numbers.each do |num|
                report.page.list(:list).add_row do |row|
                  row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                  row.item(:option).value(num)
                  if start_date != 27
                    13.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                    end
                  else
                    num_for_last_page.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                      row.item("value#13").value(to_format(value)) if t == num_for_last_page - 1
                    end
                  end
                  if num == call_numbers.last
                    row.item("condition_line").show
                    line_for_items(row) if shelf == library.shelves.last
                  end
                end
              end
            end
          end
        end
      end

      return report.generate
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_items_daily_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_items_daily_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:library, 'statistic_report.library'],
      [:shelf, 'activerecord.models.shelf'],
      [:condition, 'statistic_report.condition'],
      [:option, 'statistic_report.option'] 
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    days = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      days.times do |t|
        row << I18n.t('statistic_report.date', :num => t+1)
        columns << ["#{term}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"

      # items all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :library 
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << ""
        when :option
          row << ""
        when "sum"
          logger.error "sum: #{term}#{days+1}"
          value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << I18n.t('statistic_report.all_library')
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.attributes.item.call_number')
            when :option
              row << num
            when "sum"
              value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => 0, :call_number => num).first.value rescue 0
              row << to_format(value)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => 0, :call_number => num).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << I18n.t('statistic_report.all_library')
          when :shelf
            row << ""
          when :condition
            row << I18n.t('activerecord.models.checkout_type')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # missing items
      row = []
      columns.each do |column|
        case column[0]
        when :library 
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << I18n.t('statistic_report.missing_items')
        when :option
          row << ""
        when "sum"
          value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :option => 1, :library_id => 0).first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :option => 1, :library_id => 0).first.value rescue 0
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # items each library
      libraries.each do |library|
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << library.display_name
          when :shelf
            row << ""
          when :condition
            row << ""
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            row = []
            columns.each do |column|
              case column[0]
              when :library 
                row << library.display_name
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.attributes.item.call_number')
              when :option
                row << num
              when "sum"
                value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => library.id, :call_number => num).first.value rescue 0
                row << to_format(value)
              else
                value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id, :call_number => num).first.value rescue 0
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << library.display_name
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.models.checkout_type')
            when :option
              row << checkout_type.display_name.localize
            when "sum"
              value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # missing items
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << library.display_name
          when :shelf
            row << ""
          when :condition
            row << I18n.t('statistic_report.missing_items')
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymm => "#{term}#{days+1}", :data_type => 211, :option => 1, :library_id => library.id).first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 211, :option => 1, :library_id => library.id).first.value rescue 0 
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # items each shelves and call_numbers
        library.shelves.each do |shelf|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << library.display_name.localize
            when :shelf
              row << shelf.display_name.localize
            when :condition
              row << I18n.t('activerecord.models.checkout_type')
            when :option
              row << ""
            when "sum"
              value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => library.id, :shelf_id => shelf.id).first.value rescue 0
              row << to_format(value)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id, :shelf_id => shelf.id).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
          unless call_numbers.nil?
            call_numbers.each do |num|
              row = []
              columns.each do |column|
                case column[0]
                when :library 
                  row << library.display_name.localize
                when :shelf
                  row << shelf.display_name.localize
                when :condition
                  row << I18n.t('activerecord.attributes.item.call_number')
                when :option
                  row << num
                when "sum"
                  value = Statistic.where(:yyyymmdd => "#{term}#{days+1}", :data_type => 211, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  row << to_format(value)
                else
                  value = Statistic.where(:yyyymmdd => column[0], :data_type => 211, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  row << to_format(value)
                end
              end
              output.print row.join(",")+"\n"
            end
          end
        end
      end
    end
    return csv_file
  end

  def self.get_items_monthly_pdf(term)
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/items_monthly"

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
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0).no_condition.first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
          row.item("condition_line").show
        end  
      end
      # items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
            row.item(:option).value(num)
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
              row.item("condition_line").show if num == call_numbers.last
            end  
          end
        end
      end
      # items each checkout_types
      checkout_types.each do |checkout_type|
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
          row.item(:option).value(checkout_type.display_name.localize)
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
            row.item("condition_line").show if checkout_type == checkout_types.last
          end  
        end
      end
      # missing items
      report.page.list(:list).add_row do |row|
        row.item(:condition).value(I18n.t('statistic_report.missing_items'))
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => 0).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
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
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
            row.item("condition_line").show
          end  
        end
        # items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
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
                row.item("value#{t+1}").value(to_format(value))
                row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
                row.item("condition_line").show if num == call_numbers.last
              end
            end
          end
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
              row.item(:condition_line).show if checkout_type == checkout_types.last
            end
          end
        end
        # missing items
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(I18n.t('statistic_report.missing_items'))
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :option => 1, :library_id => library.id).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
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
              row.item("value#{t+1}").value(to_format(value))
              row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
              row.item("condition_line").show
            end
            line_for_items(row) if shelf == library.shelves.last && call_numbers.nil?
          end
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                12.times do |t|
                  if t < 4 # for Japanese fiscal year
                    value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  else
                    value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  end
                  row.item("value#{t+1}").value(to_format(value))
                  row.item("valueall").value(to_format(value)) if t == 2 # March(end of fiscal year)
                  if num == call_numbers.last
                    row.item("condition_line").show
                    line_for_items(row) if shelf == library.shelves.last
                  end
                end
              end
            end
          end
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_items_monthly_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_items_monthly_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:library, 'statistic_report.library'],
      [:shelf, 'activerecord.models.shelf'],
      [:condition, 'statistic_report.condition'],
      [:option, 'statistic_report.option'] 
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      9.times do |t|
        row << I18n.t('statistic_report.month', :num => t+4)
        columns << ["#{term}#{"%02d" % (t + 4)}"]
      end
      3.times do |t|
        row << I18n.t('statistic_report.month', :num => t+1)
        columns << ["#{term.to_i + 1}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      # items all libraries
      row = []
      columns.each do |column|
        case column[0]
        when :library 
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << ""
        when :option
          row << ""
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i+1}03}", :data_type => 111, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0).no_condition.first.value rescue 0
          row << to_format(value)
        end   
      end
      output.print row.join(",")+"\n"
      # items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << I18n.t('statistic_report.all_library')
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.attributes.item.call_number')
            when :option
              row << num
            when "sum"
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 111, :library_id => 0, :call_number => num).first.value rescue 0
              row << to_format(value)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => 0, :call_number => num).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end   
      end
      # items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << I18n.t('statistic_report.all_library')
          when :shelf
            row << ""
          when :condition
            row << I18n.t('activerecord.models.checkout_type')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :checkout_type_id => checkout_type.id).first.value rescue 0
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # missing items
      row = []
      columns.each do |column|
        case column[0]
        when :library 
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << I18n.t('statistic_report.missing_items')
        when :option
          row << ""
        when "sum"
          value = Statistic.where(:yyyymm => "#{term.to_i + 1}03}", :data_type => 111, :option => 1, :library_id => 0).first.value rescue 0
          row << to_format(value)
        else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :option => 1, :library_id => 0).first.value rescue 0
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # items each library
      libraries.each do |library|
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << library.display_name
          when :shelf
            row << ""
          when :condition
            row << ""
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id).no_condition.first.value rescue 0 
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            row = []
            columns.each do |column|
              case column[0]
              when :library 
                row << library.display_name
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.attributes.item.call_number')
              when :option
                row << num
              when "sum"
                datas = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => library.id, :call_number => num)
                value = 0
                datas.each do |data|
                  value += data.value
                end
                row << to_format(value)
              else
                datas = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :call_number => num)
                value = 0
                datas.each do |data|
                  value += data.value
                end
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
        end
        # items each checkout_types
        checkout_types.each do |checkout_type|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << library.display_name
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.models.checkout_type')
            when :option
              row << checkout_type.display_name.localize
            when "sum"
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            else
                value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :checkout_type_id => checkout_type.id).first.value rescue 0
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # missing items
        row = []
        columns.each do |column|
          case column[0]
          when :library 
            row << library.display_name
          when :shelf
            row << ""
          when :condition
            row << I18n.t('statistic_report.missing_items')
          when :option
            row << ""
          when "sum"
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :option => 1, :library_id => library.id).first.value rescue 0 
            row << to_format(value)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :option => 1, :library_id => library.id).first.value rescue 0 
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # items each shelves and call_numbers
        library.shelves.each do |shelf|
          row = []
          columns.each do |column|
            case column[0]
            when :library 
              row << library.display_name
            when :shelf
              row << shelf.display_name.localize
            when :condition
              row << ""
            when :option
              row << ""
            when "sum"
              datas = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => library.id, :shelf_id => shelf.id)
              value = 0
              datas.each do |data|
                value += data.value
              end
              row << to_format(value)
            else
              datas = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :shelf_id => shelf.id)
              value = 0
              datas.each do |data|
                value += data.value
              end
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
          unless call_numbers.nil?
            call_numbers.each do |num|
              row = []
              columns.each do |column|
                case column[0]
                when :library 
                  row << library.display_name
                when :shelf
                  row << shelf.display_name.localize
                when :condition
                  row << I18n.t('activerecord.attributes.item.call_number')
                when :option
                  row << num
                when "sum"
                  value = Statistic.where(:yyyymm => "#{term.to_i + 1}03", :data_type => 111, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  row << to_format(value)
                else
                  value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :shelf_id => shelf.id, :call_number => num).first.value rescue 0
                  row << to_format(value)
                end
              end
              output.print row.join(",")+"\n"
            end
          end
        end
      end
    end
    return csv_file
  end

  def self.get_inout_daily_pdf(term)
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    logger.error "create daily inout items statistic report: #{term}"

    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/inout_items_daily"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      num_for_last_page = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i - 26
      [1,14,27].each do |start_date| # for 3 pages
        # accept items
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:year).value(term[0,4])
        report.page.item(:month).value(term[4,6])        
        report.page.item(:inout_type).value(I18n.t('statistic_report.accept'))
        # header
        if start_date != 27
          13.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
          end
        else
          num_for_last_page.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
          end
          report.page.list(:list).header.item("column#13").value(I18n.t('statistic_report.sum'))
        end
        # accept items all libraries
        data_type = 211
        report.page.list(:list).add_row do |row|
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
              if t == num_for_last_page - 1
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :option => 2)
                datas.each do |data|
                  sum += data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
          row.item(:condition_line).show
        end
        # accept items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :call_number => num, :option => 2)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item("condition_line").show if num == call_numbers.last
            end  
          end
        end
        # accept items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                if t == num_for_last_page - 1
                  sum = 0
                  datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2)
                  datas.each do |data|
                    sum += data.value
                  end
                  row.item("value#13").value(sum)
                end
              end
            end  
            row.item("condition_line").show if checkout_type == checkout_types.last
            line_for_items(row) if checkout_type == checkout_types.last
          end
        end
        # accept items each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                if t == num_for_last_page - 1
                  sum = 0
                  datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :option => 2)
                  datas.each do |data|
                    sum += data.value
                  end
                  row.item("value#13").value(sum)
                end
              end
            end
            row.item(:condition_line).show
          end
          # accept items each call_numbers
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                if start_date != 27
                  13.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                  end
                else
                  num_for_last_page.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                    if t == num_for_last_page - 1
                      sum = 0
                      datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2)
                      datas.each do |data|
                        sum += data.value
                      end
                      row.item("value#13").value(sum)
                    end
                  end
                end
                row.item("condition_line").show if num == call_numbers.last
              end
            end
          end
          # accept items each checkout_types
          checkout_types.each do |checkout_type|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
              row.item(:option).value(checkout_type.display_name.localize)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item(:condition_line).show if checkout_type == checkout_types.last
            end
          end
          # accept items each shelves and call_numbers
          library.shelves.each do |shelf|
            report.page.list(:list).add_row do |row|
              row.item(:library).value("(#{shelf.display_name})")
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else 
                 num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 2).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 2)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item("condition_line").show
              line_for_items(row) if shelf == library.shelves.last && call_numbers.nil?
            end
            unless call_numbers.nil?
              call_numbers.each do |num|
                report.page.list(:list).add_row do |row|
                  row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                  row.item(:option).value(num)
                  if start_date != 27
                    13.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                    end
                  else
                    num_for_last_page.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                      if t == num_for_last_page - 1
                        sum = 0
                        datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2)
                        datas.each do |data|
                          sum += data.value
                        end
                        row.item("value#13").value(sum)
                      end
                    end
                  end
                  if num == call_numbers.last
                    row.item("condition_line").show
                    line_for_items(row) if shelf == library.shelves.last
                  end
                end
              end
            end
          end
        end

        # remove items
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:year).value(term[0,4])
        report.page.item(:month).value(term[4,6])        
        report.page.item(:inout_type).value(I18n.t('statistic_report.remove'))
        # header
        if start_date != 27
          13.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}#{t('statistic_report.date')}")
          end
        else
          num_for_last_page.times do |t|
            report.page.list(:list).header.item("column##{t+1}").value("#{t+start_date}#{t('statistic_report.date')}")
          end
          report.page.list(:list).header.item("column#13").value(I18n.t('statistic_report.sum'))
        end
        # remove items all libraries
        data_type = 211
        report.page.list(:list).add_row do |row|
          row.item(:library).value(I18n.t('statistic_report.all_library'))
          if start_date != 27
            13.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
            end
          else
            num_for_last_page.times do |t|
              value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
              row.item("value##{t+1}").value(to_format(value))
              if t == num_for_last_page - 1
                sum = 0
                datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :option => 3)
                datas.each do |data|
                  sum += data.value
                end
                row.item("value#13").value(sum)
              end
            end
          end
          row.item(:condition_line).show
        end
        # remove items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :call_number => num, :option => 3)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item("condition_line").show if num == call_numbers.last
            end  
          end
        end
        # remove items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                if t == num_for_last_page - 1
                  sum = 0
                  datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3)
                  datas.each do |data|
                    sum += data.value
                  end
                  row.item("value#13").value(sum)
                end
              end
            end  
            row.item("condition_line").show if checkout_type == checkout_types.last
            line_for_items(row) if checkout_type == checkout_types.last
          end
        end
        # remove items each libraries
        libraries.each do |library|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(library.display_name)
            if start_date != 27
              13.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
              end
            else
              num_for_last_page.times do |t|
                value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0
                row.item("value##{t+1}").value(to_format(value))
                if t == num_for_last_page - 1
                  sum = 0
                  datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :option => 3)
                  datas.each do |data|
                    sum += data.value
                  end
                  row.item("value#13").value(sum)
                end
              end
            end
            row.item(:condition_line).show
          end
          # remove items each call_numbers
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                if start_date != 27
                  13.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 3).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                  end
                else
                  num_for_last_page.times do |t|
                    value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 3).first.value rescue 0
                    row.item("value##{t+1}").value(to_format(value))
                    if t == num_for_last_page - 1
                      sum = 0
                      datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :call_number => num, :option => 3)
                      datas.each do |data|
                        sum += data.value
                      end
                      row.item("value#13").value(sum)
                    end
                  end
                end
                row.item("condition_line").show if num == call_numbers.last
              end
            end
          end
          # remove items each checkout_types
          checkout_types.each do |checkout_type|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
              row.item(:option).value(checkout_type.display_name.localize)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item(:condition_line).show if checkout_type == checkout_types.last
            end
          end
          # remove items each shelves and call_numbers
          library.shelves.each do |shelf|
            report.page.list(:list).add_row do |row|
              row.item(:library).value("(#{shelf.display_name})")
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else 
                 num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 3).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 3)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item("condition_line").show
              line_for_items(row) if shelf == library.shelves.last && call_numbers.nil?
            end
            unless call_numbers.nil?
              call_numbers.each do |num|
                report.page.list(:list).add_row do |row|
                  row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                  row.item(:option).value(num)
                  if start_date != 27
                    13.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                    end
                  else
                    num_for_last_page.times do |t|
                      value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3).first.value rescue 0
                      row.item("value##{t+1}").value(to_format(value))
                      if t == num_for_last_page - 1
                        sum = 0
                        datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3)
                        datas.each do |data|
                          sum += data.value
                        end
                        row.item("value#13").value(sum)
                      end
                    end
                  end
                  if num == call_numbers.last
                    row.item("condition_line").show
                    line_for_items(row) if shelf == library.shelves.last
                  end
                end
              end
            end
          end
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_inout_daily_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_inout_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:library, 'statistic_report.library'],
      [:shelf, 'activerecord.models.shelf'],
      [:condition, 'statistic_report.condition'],
      [:option, 'statistic_report.option'] 
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    days = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      days.times do |t|
        row << I18n.t('statistic_report.date', :num => t+1)
        columns << ["#{term}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"

      data_type = 211
      # accept items all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :library
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << ""
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"    
      # accept items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :library
              row << I18n.t('statistic_report.all_library')
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.attributes.item.call_number')
            when :option
              row << num
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # accept items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :library
            row << I18n.t('statistic_report.all_library')
          when :shelf
            row << ""
          when :condition
            row << I18n.t('activerecord.models.checkout_type')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # accept items each libraries
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :library
            row << library.display_name.localize
          when :shelf
            row << ""
          when :condition
            row << ""
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # accept items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            row = []
            sum = 0
            columns.each do |column|
              case column[0]
              when :library
                row << library.display_name.localize
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.attributes.item.call_number')
              when :option
                row << num
              when "sum"
                row << to_format(sum)
              else
                value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                sum += value
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
          # accept items each checkout_types
          checkout_types.each do |checkout_type|
            row = []
            sum = 0
            columns.each do |column|
              case column[0]
              when :library
                row << library.display_name.localize
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.models.checkout_type')
              when :option
                row << checkout_type.display_name.localize
              when "sum"
                row << to_format(sum)
              else
                value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
                sum += value
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
          # accept items each shelves and call_numbers
          library.shelves.each do |shelf|
            row = []
            sum = 0
            columns.each do |column|
              case column[0]
              when :library
                row << library.display_name.localize
              when :shelf
                row << shelf.display_name.localize
              when :condition
                row << ""
              when :option
                row << ""
              when "sum"
                row << to_format(sum)
              else
                value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => nil, :option => 2).first.value rescue 0
                sum += value
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
            unless call_numbers.nil?
              call_numbers.each do |num|
                row = []
                sum = 0
                columns.each do |column|
                  case column[0]
                  when :library
                    row << library.display_name.localize
                  when :shelf
                    row << shelf.display_name.localize
                  when :condition
                    row << I18n.t('activerecord.attributes.item.call_number')
                  when :option
                    row << num
                  when "sum"
                    row << to_format(sum)
                  else
                    value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                    sum += value
                    row << to_format(value)
                  end
                end
                output.print row.join(",")+"\n"
              end
            end
          end
        end
      end
    end
    return csv_file
  end

  def self.get_inout_monthly_pdf(term)
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    begin 
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/inout_items_monthly"

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

      # accept items
      report.page.item(:inout_type).value(I18n.t('statistic_report.accept'))
      
      # accept items all libraries
      data_type = 111
      report.page.list(:list).add_row do |row|
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 2).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum += value
        end  
        row.item("valueall").value(sum)
        row.item("condition_line").show
      end
      # accept items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
            row.item(:option).value(num)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end  
            row.item("valueall").value(sum)
            row.item("condition_line").show if num == call_numbers.last
          end
        end
      end
      # accept items each checkout_types
      checkout_types.each do |checkout_type|
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
          row.item(:option).value(checkout_type.display_name.localize)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end  
          row.item("valueall").value(sum)
          row.item("condition_line").show if checkout_type == checkout_types.last
          line_for_items(row) if checkout_type == checkout_types.last
        end
      end
      # accept items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end  
          row.item("valueall").value(sum)
          row.item("condition_line").show
        end
        # accept items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              sum = 0
              12.times do |t|
                if t < 4 # for Japanese fiscal year
                  value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                else
                  value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                end
                row.item("value#{t+1}").value(to_format(value))
                sum += value
              end
              row.item("valueall").value(sum)
              row.item("condition_line").show if num == call_numbers.last
            end
          end
        end
        # accept items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item(:condition_line).show if checkout_type == checkout_types.last
          end
        end
        # accept items each shelves and call_numbers
        library.shelves.each do |shelf|
          report.page.list(:list).add_row do |row|
            row.item(:library).value("(#{shelf.display_name})")
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :option => 2).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :option => 2).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item("condition_line").show
            line_for_items(row) if shelf == library.shelves.last && call_numbers.nil?
          end
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                sum = 0
                12.times do |t|
                  if t < 4 # for Japanese fiscal year
                    value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                  else
                    value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                  end
                  row.item("value#{t+1}").value(to_format(value))
                  sum += value
                end
                row.item("valueall").value(sum)
                if num == call_numbers.last
                  row.item("condition_line").show
                  line_for_items(row) if shelf == library.shelves.last
                end
              end
            end
          end
        end
      end

      # remove items
      report.start_new_page
      report.page.item(:date).value(Time.now)       
      report.page.item(:term).value(term)
      report.page.item(:inout_type).value(I18n.t('statistic_report.remove'))
      
      # remove items all libraries
      data_type = 111
      report.page.list(:list).add_row do |row|
        row.item(:library).value(I18n.t('statistic_report.all_library'))
        sum = 0
        12.times do |t|
          if t < 4 # for Japanese fiscal year
            value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          else
            value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :option => 3).first.value rescue 0
          end
          row.item("value#{t+1}").value(to_format(value))
          sum += value
        end  
        row.item("valueall").value(sum)
        row.item("condition_line").show
      end
      # remove items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
            row.item(:option).value(num)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 3).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :call_number => num, :option => 3).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end  
            row.item("valueall").value(sum)
            row.item("condition_line").show if num == call_numbers.last
          end
        end
      end
      # remove items each checkout_types
      checkout_types.each do |checkout_type|
        report.page.list(:list).add_row do |row|
          row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
          row.item(:option).value(checkout_type.display_name.localize)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end  
          row.item("valueall").value(sum)
          row.item("condition_line").show if checkout_type == checkout_types.last
          line_for_items(row) if checkout_type == checkout_types.last
        end
      end
      # remove items each library
      libraries.each do |library|
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name)
          sum = 0
          12.times do |t|
            if t < 4 # for Japanese fiscal year
              value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            else
              value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :option => 3).first.value rescue 0 
            end
            row.item("value#{t+1}").value(to_format(value))
            sum += value
          end  
          row.item("valueall").value(sum)
          row.item("condition_line").show
        end
        # remove items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            report.page.list(:list).add_row do |row|
              row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
              row.item(:option).value(num)
              sum = 0
              12.times do |t|
                if t < 4 # for Japanese fiscal year
                  datas = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 3)
                else
                  datas = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :call_number => num, :option => 3)
                end
                value = 0
                datas.each do |data|
                  value += data.value
                end
                row.item("value#{t+1}").value(to_format(value))
                sum += value
              end
              row.item("valueall").value(sum)
              row.item("condition_line").show if num == call_numbers.last
            end
          end
        end
        # remove items each checkout_types
        checkout_types.each do |checkout_type|
          report.page.list(:list).add_row do |row|
            row.item(:condition).value(I18n.t('activerecord.models.checkout_type')) if checkout_type == checkout_types.first 
            row.item(:option).value(checkout_type.display_name.localize)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item(:condition_line).show if checkout_type == checkout_types.last
          end
        end
        # remove items each shelves and call_numbers
        library.shelves.each do |shelf|
          report.page.list(:list).add_row do |row|
            row.item(:library).value("(#{shelf.display_name})")
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                datas = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :option => 3)
              else
                datas = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :option => 3)
              end
              value = 0
              datas.each do |data|
                value += data.value
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item("condition_line").show
            line_for_items(row) if shelf == library.shelves.last && call_numbers.nil?
          end
          unless call_numbers.nil?
            call_numbers.each do |num|
              report.page.list(:list).add_row do |row|
                row.item(:condition).value(I18n.t('activerecord.attributes.item.call_number')) if num == call_numbers.first 
                row.item(:option).value(num)
                sum = 0
                12.times do |t|
                  if t < 4 # for Japanese fiscal year
                    value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3).first.value rescue 0
                  else
                    value = Statistic.where(:yyyymm => "#{term}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3).first.value rescue 0
                  end
                  row.item("value#{t+1}").value(to_format(value))
                  sum += value
                end
                row.item("valueall").value(sum)
                if num == call_numbers.last
                  row.item("condition_line").show
                  line_for_items(row) if shelf == library.shelves.last
                end
              end
            end
          end
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_inout_monthly_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_inout_report.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:type,'statistic_report.type'],
      [:library, 'statistic_report.library'],
      [:shelf, 'activerecord.model.shelf'],
      [:condition, 'statistic_report.condition'],
      [:option, 'statistic_report.option']
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      9.times do |t|
        row << I18n.t('statistic_report.month', :num => t+4)
        columns << ["#{term}#{"%02d" % (t + 4)}"]
      end
      3.times do |t|
        row << I18n.t('statistic_report.month', :num => t+1)
        columns << ["#{term.to_i + 1}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      # accept items all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.accept')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << ""
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :option => 2).first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # accept items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.accept')
            when :library
              row << I18n.t('statistic_report.all_library')
            when :shelf
               row << ""
            when :condition
              row << I18n.t('activerecord.attributes.item.call_number')
            when :option
              row << num
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :call_number => num, :option => 2).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # accept items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.accept')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :shelf
            row << ""
          when :condition
            row << I18n.t('activerecord.models.checkout_type')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # accept items each library
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.accept')
          when :shelf
            row << ""
          when :library
            row << library.display_name.localize
          when :condition
            row << ""
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :option => 2).first.value rescue 0 
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # accept items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            row = []
            sum = 0
            columns.each do |column|
              case column[0]
              when :type
                row << I18n.t('statistic_report.accept')
              when :library
                row << library.display_name.localize
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.attributes.item.call_number')
              when :option
                row << num
              when "sum"
                row << to_format(sum)
              else
                value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :call_number => num, :option => 2).first.value rescue 0
                sum += value
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
        end
        # accept items each checkout_types
        checkout_types.each do |checkout_type|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.accept')
            when :library
              row << library.display_name.localize
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.models.checkout_type')
            when :option
              row << checkout_type.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 2).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # accept items each shelves and call_numbers
        library.shelves.each do |shelf|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.accept')
            when :library
              row << library.display_name.localize
            when :shelf
              row << shelf.display_name.localize
            when :condition
              row << ""
            when :option
              row << ""
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :shelf_id => shelf.id, :option => 2).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
          unless call_numbers.nil?
            call_numbers.each do |num|
              row = []
              sum = 0
              columns.each do |column|
                case column[0]
                when :type
                  row << I18n.t('statistic_report.accept')
                when :library
                  row << library.display_name.localize
                when :shelf
                  row << shelf.display_name.localize
                when :condition
                  row << I18n.t('activerecord.attributes.item.call_number')
                when :option
                  row << num
                when "sum"
                  row << to_format(sum)
                else
                  value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 2).first.value rescue 0
                  sum += value
                  row << to_format(value)
                end
              end
              output.print row.join(",")+"\n"
            end
          end
        end
      end
      # remove items all libraries
      row = []
      sum = 0
      columns.each do |column|
        case column[0]
        when :type
          row << I18n.t('statistic_report.remove')
        when :library
          row << I18n.t('statistic_report.all_library')
        when :shelf
          row << ""
        when :condition
          row << ""
        when :option
          row << ""
        when "sum"
          row << to_format(sum)
        else
          value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :option => 3).first.value rescue 0
          sum += value
          row << to_format(value)
        end
      end
      output.print row.join(",")+"\n"
      # remove items each call_numbers
      unless call_numbers.nil?
        call_numbers.each do |num|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.remove')
            when :library
              row << I18n.t('statistic_report.all_library')
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.attributes.item.call_number')
            when :option
              row << num
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :call_number => num, :option => 3).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
      # remove items each checkout_types
      checkout_types.each do |checkout_type|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.remove')
          when :library
            row << I18n.t('statistic_report.all_library')
          when :shelf
            row << ""
          when :condition
            row << I18n.t('activerecord.models.checkout_type')
          when :option
            row << checkout_type.display_name.localize
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => 0, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
      end
      # remove items each library
      libraries.each do |library|
        row = []
        sum = 0
        columns.each do |column|
          case column[0]
          when :type
            row << I18n.t('statistic_report.remove')
          when :library
            row << library.display_name.localize
          when :shelf
            row << ""
          when :condition
            row << ""
          when :option
            row << ""
          when "sum"
            row << to_format(sum)
          else
            value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :option => 3).first.value rescue 0 
            sum += value
            row << to_format(value)
          end
        end
        output.print row.join(",")+"\n"
        # remove items each call_numbers
        unless call_numbers.nil?
          call_numbers.each do |num|
            row = []
            sum = 0
            columns.each do |column|
              case column[0]
              when :type
                row << I18n.t('statistic_report.remove')
              when :library
                row << library.display_name.localize
              when :shelf
                row << ""
              when :condition
                row << I18n.t('activerecord.attributes.item.call_number')
              when :option
                row << num
              when "sum"
                row << to_format(sum)
              else
                datas = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :call_number => num, :option => 3)
                value = 0
                datas.each do |data|
                  value += data.value
                end
                sum += value
                row << to_format(value)
              end
            end
            output.print row.join(",")+"\n"
          end
        end
        # remove items each checkout_types
        checkout_types.each do |checkout_type|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.remove')
            when :library
              row << library.display_name.localize
            when :shelf
              row << ""
            when :condition
              row << I18n.t('activerecord.models.checkout_type')
            when :option
              row << checkout_type.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :checkout_type_id => checkout_type.id, :option => 3).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # remove items each shelves and call_numbers
        library.shelves.each do |shelf|
          row = []
          sum = 0
          columns.each do |column|
            case column[0]
            when :type
              row << I18n.t('statistic_report.remove')
            when :library
              row << library.display_name.localize
            when :shelf
              row << shelf.display_name.localize
            when :condition
              row << ""
            when :option
              row << ""
            when "sum"
              row << to_format(sum)
            else
              value = 0
              datas = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :shelf_id => shelf.id, :option => 3)
              datas.each do |data|
                value += data.value
              end
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
          unless call_numbers.nil?
            call_numbers.each do |num|
              row = []
              sum = 0
              columns.each do |column|
                case column[0]
                when :type
                  row << I18n.t('statistic_report.remove')
                when :library
                  row << library.display_name.localize
                when :shelf
                  row << shelf.display_name.localize
                when :condition
                  row << I18n.t('activerecord.attributes.item.call_number')
                when :option
                  row << num
                when "sum"
                  row << to_format(sum)
                else
                  value = Statistic.where(:yyyymm => column[0], :data_type => 111, :library_id => library.id, :shelf_id => shelf.id, :call_number => num, :option => 3).first.value rescue 0
                  sum += value
                  row << to_format(value)
                end
              end
              output.print row.join(",")+"\n"
            end
          end
        end
      end
    end
    return csv_file
  end

  def self.get_loans_daily_pdf(term)
    logger.error "create daily inter library loans statistic report: #{term}"
    libraries = Library.all
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/loans_daily"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      num_for_last_page = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i - 26
      libraries.each do |library|
        [1,14,27].each do |start_date| # for 3 pages
          report.start_new_page
          report.page.item(:date).value(Time.now)
          report.page.item(:year).value(term[0,4])
          report.page.item(:month).value(term[4,6])        
          report.page.item(:library).value(library.display_name.localize)        
          # header
          if start_date != 27
            13.times do |t|
              report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
            end
          else
            num_for_last_page.times do |t|
              report.page.list(:list).header.item("column##{t+1}").value(I18n.t('statistic_report.date', :num => t+start_date))
            end
            report.page.list(:list).header.item("column#13").value(I18n.t('statistic_report.sum'))
          end
          # checkout loan
          data_type = 261
          libraries.each do |borrowing_library|
            next if library == borrowing_library
            report.page.list(:list).add_row do |row|
              row.item(:loan_type).value(I18n.t('statistic_report.checkout_loan')) if borrowing_library == libraries.first || (borrowing_library == libraries[1] && library == libraries.first)
              row.item(:borrowing_library).value(borrowing_library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item(:type_line).show if borrowing_library == libraries.last || (borrowing_library == libraries[-2] && library == libraries.last)
            end
          end
          # checkin loan
          data_type = 262
          libraries.each do |borrowing_library|
            next if library == borrowing_library
            report.page.list(:list).add_row do |row|
              row.item(:loan_type).value(I18n.t('statistic_report.checkin_loan')) if borrowing_library == libraries.first || (borrowing_library == libraries[1] && library == libraries.first)
              row.item(:borrowing_library).value(borrowing_library.display_name)
              if start_date != 27
                13.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                end
              else
                num_for_last_page.times do |t|
                  value = Statistic.where(:yyyymmdd => "#{term.to_i}#{"%02d" % (t + start_date)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
                  row.item("value##{t+1}").value(to_format(value))
                  if t == num_for_last_page - 1
                    sum = 0
                    datas = Statistic.where(:yyyymm => term, :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id)
                    datas.each do |data|
                      sum += data.value
                    end
                    row.item("value#13").value(sum)
                  end
                end
              end
              row.item(:type_line).show if borrowing_library == libraries.last
            end
          end
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_loans_daily_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_loans_daily.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:library, 'statistic_report.library'],
      [:loan_type, 'statistic_report.loan_type'],
      [:loan_library, 'statistic_report.loan_library'] 
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    days = Time.zone.parse("#{term}01").end_of_month.strftime("%d").to_i
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      days.times do |t|
        row << I18n.t('statistic_report.date', :num => t+1)
        columns << ["#{term}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"
      libraries.each do |library|
        # checkout loan
        data_type = 261
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :library
              row << library.display_name.localize
            when :loan_type
              row << I18n.t('statistic_report.checkout_loan')
            when :loan_library
              row << borrowing_library.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # checkin loan
        data_type = 262
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :library
              row << library.display_name.localize
            when :loan_type
              row << I18n.t('statistic_report.checkin_loan')
            when :loan_library
              row << borrowing_library.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymmdd => column[0], :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
    end
    return csv_file
  end

  def self.get_loans_monthly_pdf(term)
    logger.error "create monthly inter library loans statistic report: #{term}"
    libraries = Library.all
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/statistic_reports/loans_monthly"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      libraries.each do |library|
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:term).value(term)
        report.page.item(:library).value(library.display_name.localize)        
        # checkout loan
        data_type = 161
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          report.page.list(:list).add_row do |row|
            row.item(:loan_type).value(I18n.t('statistic_report.checkout_loan')) if borrowing_library == libraries.first || (borrowing_library == libraries[1] && library == libraries.first)
            row.item(:borrowing_library).value(borrowing_library.display_name)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term.to_i}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item(:type_line).show if borrowing_library == libraries.last || (borrowing_library == libraries[-2] && library == libraries.last)
          end
        end
        # checkin loan
        data_type = 162
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          report.page.list(:list).add_row do |row|
            row.item(:loan_type).value(I18n.t('statistic_report.checkin_loan')) if borrowing_library == libraries.first || (borrowing_library == libraries[1] && library == libraries.first)
            row.item(:borrowing_library).value(borrowing_library.display_name)
            sum = 0
            12.times do |t|
              if t < 4 # for Japanese fiscal year
                value = Statistic.where(:yyyymm => "#{term.to_i + 1}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              else
                value = Statistic.where(:yyyymm => "#{term.to_i}#{"%02d" % (t + 1)}", :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              end
              row.item("value#{t+1}").value(to_format(value))
              sum += value
            end
            row.item("valueall").value(sum)
            row.item(:type_line).show if borrowing_library == libraries.last || (borrowing_library == libraries[-2] && library == libraries.last)
          end
        end
      end

      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_loans_monthly_csv(term)
    dir_base = "#{RAILS_ROOT}/private/system"
    out_dir = "#{dir_base}/statistic_report/"
    csv_file = out_dir + "#{term}_loans_monthly.csv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      [:library, 'statistic_report.library'],
      [:loan_type, 'statistic_report.loan_type'],
      [:loan_library, 'statistic_report.loan_library'] 
    ]
    libraries = Library.all
    checkout_types = CheckoutType.all
    call_numbers = Statistic.call_numbers
    File.open(csv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      9.times do |t|
        row << I18n.t('statistic_report.month', :num => t+4)
        columns << ["#{term}#{"%02d" % (t + 4)}"]
      end
      3.times do |t|
        row << I18n.t('statistic_report.month', :num => t+1)
        columns << ["#{term.to_i + 1}#{"%02d" % (t + 1)}"]
      end
      row << I18n.t('statistic_report.sum')
      columns << ["sum"]
      output.print row.join(",")+"\n"

      libraries.each do |library|
        # checkout loan
        data_type = 161
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :library
              row << library.display_name.localize
            when :loan_type
              row << I18n.t('statistic_report.checkout_loan')
            when :loan_library
              row << borrowing_library.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
        # checkin loan
        data_type = 162
        libraries.each do |borrowing_library|
          next if library == borrowing_library
          sum = 0
          row = []
          columns.each do |column|
            case column[0]
            when :library
              row << library.display_name.localize
            when :loan_type
              row << I18n.t('statistic_report.checkin_loan')
            when :loan_library
              row << borrowing_library.display_name.localize
            when "sum"
              row << to_format(sum)
            else
              value = Statistic.where(:yyyymm => column[0], :data_type => data_type, :library_id => library.id, :borrowing_library_id => borrowing_library.id).first.value rescue 0
              sum += value
              row << to_format(value)
            end
          end
          output.print row.join(",")+"\n"
        end
      end
    end
    return csv_file
  end

private
  def self.line(row)
    row.item(:type_line).show
    row.item(:library_line).show
    row.item(:library_line).style(:border_color, '#000000')
    row.item(:library_line).style(:border_width, 1)
    row.item(:option_line).style(:border_color, '#000000')
    row.item(:option_line).style(:border_width, 1)
    row.item(:values_line).style(:border_color, '#000000')
    row.item(:values_line).style(:border_width, 1)
  end

  def self.line_for_items(row)
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

  def self.to_format(num = 0)
    num.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,') 
  end

end
