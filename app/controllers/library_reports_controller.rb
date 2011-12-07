class LibraryReportsController < ApplicationController
  load_and_authorize_resource

  def index
    @library_reports = LibraryReport.all
    @libraries = Library.all
    @months = @library_reports.inject([]){|months, data| months << data.yyyymm}.uniq
  end

  def new
    @library_report = LibraryReport.new
    @libraries = Library.all
  end

  def daily_report
   @library_report = LibraryReport.find(params[:id])
   library = @library_report.library
   yyyy = @library_report.yyyymmdd.to_s[0,4]
   mm = @library_report.yyyymmdd.to_s[4,2]
   dd = @library_report.yyyymmdd.to_s[6,2]
   yyyymmdd = @library_report.yyyymmdd.to_s
   visiters = @library_report.visiters
   copies = @library_report.copies
   consultations = @library_report.consultations
   begin
     report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/library_reports/daily_library_report"

      report.start_new_page
      report.page.item(:year).value(yyyy)
      report.page.item(:month).value(mm)
      report.page.item(:date).value(dd)

      @checkout_datas = Statistic.where(["yyyymmdd = ? AND library_id = ? AND ndc IS NOT NULL", yyyymmdd, library.id])
      report.page.list(:list).add_row do |row|
        row.item(:library).value(library.display_name.localize)
        row.item(:title).value(t('library_report.checkouts'))
        row.item(:value).value(@checkout_datas.inject(0){|sum, data| sum += data.value})
      end
      @checkout_datas.each do |data|
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('library_report.ndc', :ndc => data.ndc))
          row.item(:value).value(data.value)
        end  
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.visiters'))
        row.item(:value).value(visiters)
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.copies'))
        row.item(:value).value(copies)
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.consultations'))
        row.item(:value).value(consultations)
      end

      send_data report.generate, :filename => "#{yyyymmdd}_#{library.name}_report.pdf", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def create
    @library_report = LibraryReport.new(params[:library_report])

    respond_to do |format|
      if @library_report.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.library_report'))
        format.html { redirect_to(@library_report) }
        format.xml  { render :xml => @library_report, :status => :created, :location => @library_report }
      else
        @libraries = Library.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @library_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  def monthly_report
    library = Library.find(params[:library_report][:library_id])
    yyyymm = params[:library_report][:yyyymm]
    begin
     report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/library_reports/monthly_library_report"

      report.start_new_page
      report.page.item(:year).value(yyyymm.to_s[0,4])
      report.page.item(:month).value(yyyymm.to_s[4,2])
      report.page.item(:library).value(library.display_name.localize)

      @checkout_datas = Statistic.where(["yyyymm = ? AND library_id = ? AND ndc IS NOT NULL", yyyymm, library.id])
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('library_report.checkouts'))
        row.item(:value).value(@checkout_datas.inject(0){|sum, data| sum += data.value})
      end
      9.times do |i|
        @checkout_datas = Statistic.where(["yyyymm = ? AND library_id = ? AND ndc = ? ", yyyymm, library.id, (i+1).to_s])
        report.page.list(:list).add_row do |row|
          row.item(:option).value(t('library_report.ndc', :ndc => i+1))
          row.item(:value).value(@checkout_datas.inject(0){|sum, data| sum += data.value})
        end  
      end
      visiters, copies, consultations = 0, 0, 0
      @datas = LibraryReport.where(:library_id => library.id, :yyyymm => yyyymm)
      @datas.each do |data|
        visiters += data.visiters if data.visiters
        copies += data.copies if data.copies
        consultations += data.consultations if data.consultations
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.visiters'))
        row.item(:value).value(visiters)
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.copies'))
        row.item(:value).value(copies)
      end
      report.page.list(:list).add_row do |row|
        row.item(:title).value(t('activerecord.attributes.library_report.consultations'))
        row.item(:value).value(consultations)
      end

      send_data report.generate, :filename => "#{yyyymm}_#{library.name}_report.pdf", :type => 'application/pdf', :disposition => 'attachment'
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def show
    @library_report = LibraryReport.find(params[:id])
    @checkout_datas = Statistic.where(["yyyymmdd = ? AND library_id = ? AND ndc IS NOT NULL", @library_report.yyyymmdd, @library_report.library_id])
  end

  def edit
    @library_report = LibraryReport.find(params[:id])
    @libraries = Library.all
  end
  
  def destroy
    @library_report = LibraryReport.find(params[:id])
    @library_report.destroy
    respond_to do |format|
      format.html { redirect_to(library_reports_url) }
      format.xml  { head :ok }
    end
  end

end
