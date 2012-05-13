class LibraryReportsController < ApplicationController
  load_and_authorize_resource

  def index
    @count = {}
    search = Sunspot.new_search(LibraryReport)
    if params[:yyyymm]
      @yyyymm = params[:yyyymm]
    else
      @yyyymm = nil
    end
    @library = Library.find(params[:library_report][:library_id]) rescue nil if params[:library_report] && params[:library_report][:library_id]
    if @library
      library_id = @library.id
      search.build do
        with(:library_id).equal_to library_id
      end
    end
   flash[:message] = nil
    unless  @yyyymm.blank?
      unless @yyyymm =~ /^\d{6}$/ && month_term?(@yyyymm)
        logger.error t('statistic_report.invalid_month')
        flash[:message] = t('statistic_report.invalid_month')
      else 
        yyyymm = @yyyymm.to_i
        search.build do
          with(:yyyymm).equal_to yyyymm
        end
      end
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, LibraryReport.per_page)
    @library_reports = search.execute!.results
    @count[:query_result] = @library_reports.total_entries
    @libraries = Library.all
    @months = @library_reports.inject([]){|months, data| months << data.yyyymm}.uniq
    @dates = @library_reports.inject([]){|dates, data| dates << data.yyyymmdd}.uniq

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @library_reports }
      format.rss  { render :layout => false }
      format.csv
      format.atom
      format.ics
    end
  end

  def new
    @library_report = LibraryReport.new
    @library_report.yyyymmdd = Time.zone.now.strftime("%Y%m%d")
    @libraries = Library.all
  end

  def daily_report
   @library_reports = LibraryReport.where(:id => params[:id]) rescue nil
   yyyymmdd = @library_reports[0].yyyymmdd.to_s unless @library_reports.empty?
   yyyymmdd = params[:library_report][:yyyymmdd].to_s if params[:library_report] && params[:library_report][:yyyymmdd]
   library_ids = params[:library]
   @library_reports = LibraryReport.where(["yyyymmdd = ? AND library_id IN (?)", yyyymmdd, library_ids]) if library_ids

   begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/library_reports/daily_library_report"

      report.start_new_page
      report.page.item(:year).value(yyyymmdd[0,4])
      report.page.item(:month).value(yyyymmdd[4,2])
      report.page.item(:date).value(yyyymmdd[6,2])

      @library_reports.each do |library_report|
        @checkout_datas = Statistic.where(["yyyymmdd = ? AND library_id = ? AND ndc IS NOT NULL", yyyymmdd, library_report.library_id])
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library_report.library.display_name.localize)
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
          row.item(:value).value(library_report.visiters)
        end
        report.page.list(:list).add_row do |row|
          row.item(:title).value(t('activerecord.attributes.library_report.copies'))
          row.item(:value).value(library_report.copies)
        end
        report.page.list(:list).add_row do |row|
          row.item(:title).value(t('activerecord.attributes.library_report.consultations'))
          row.item(:value).value(library_report.consultations)
        end
        report.page.list(:list).add_row do |row|
          row.item(:column_line).hide
          row.item(:row_line).hide
        end
      end

      if @library_reports.size == 1
        filename = "#{yyyymmdd}_#{@library_reports[0].library.name}_report.pdf"
      else
        filename = "#{yyyymmdd}_report.pdf"
      end
      send_data report.generate, :filename => filename, :type => 'application/pdf', :disposition => 'attachment'
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
        format.json { render :json => @library_report, :status => :created, :location => @library_report }
      else
        @libraries = Library.all
        format.html { render :action => "new" }
        format.json { render :json => @library_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  def monthly_report
    yyyymm = params[:library_report][:yyyymm]
    library_ids = params[:library]
    begin
     report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/library_reports/monthly_library_report"

      report.start_new_page
      report.page.item(:year).value(yyyymm.to_s[0,4])
      report.page.item(:month).value(yyyymm.to_s[4,2])

      library_ids.each do |library_id|
        library = Library.find(library_id)
        @checkout_datas = Statistic.where(["yyyymm = ? AND library_id = ? AND ndc IS NOT NULL", yyyymm, library.id])
        report.page.list(:list).add_row do |row|
          row.item(:library).value(library.display_name.localize)
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
        visiters, consultations = 0, 0
        @datas = LibraryReport.where(:library_id => library.id, :yyyymm => yyyymm)
        @datas.each do |data|
          visiters += data.visiters unless data.visiters.nil?
          copies += data.copies unless data.copies.nil?
          consultations += data.consultations unless data.consultations.nil?
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
        report.page.list(:list).add_row do |row|
          row.item(:column_line).hide
          row.item(:row_line).hide
        end
      end

      send_data report.generate, :filename => "#{yyyymm}_report.pdf", :type => 'application/pdf', :disposition => 'attachment'
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
      format.json { head :no_content }
    end
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

end
