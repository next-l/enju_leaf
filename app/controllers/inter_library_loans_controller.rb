class InterLibraryLoansController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_item
  before_filter :store_page, :only => :index
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /inter_library_loans
  # GET /inter_library_loans.xml
  def index
    if @item
      @inter_library_loans = @item.inter_library_loans.page(params[:page])
    else
      @inter_library_loans = InterLibraryLoan.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inter_library_loans }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /inter_library_loans/1
  # GET /inter_library_loans/1.xml
  def show
    @inter_library_loan = InterLibraryLoan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inter_library_loan }
    end
  end

  # GET /inter_library_loans/new
  # GET /inter_library_loans/new.xml
  def new
    @inter_library_loan = InterLibraryLoan.new
    @libraries = LibraryGroup.first.real_libraries
    @libraries.reject!{|library| library == current_user.library}

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inter_library_loan }
    end
  end

  # GET /inter_library_loans/1/edit
  def edit
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @libraries = LibraryGroup.first.real_libraries
    @libraries.reject!{|library| library == current_user.library}
  end

  # POST /inter_library_loans
  # POST /inter_library_loans.xml
  def create
    @inter_library_loan = InterLibraryLoan.new(params[:inter_library_loan])
    item = Item.where(:item_identifier => params[:inter_library_loan][:item_identifier]).first
    @inter_library_loan.item = item

    respond_to do |format|
      if @inter_library_loan.save
        @inter_library_loan.sm_request!
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.inter_library_loan'))
        format.html { redirect_to(@inter_library_loan) }
        format.xml  { render :xml => @inter_library_loan, :status => :created, :location => @inter_library_loan }
      else
        @libraries = LibraryGroup.first.real_libraries
        @libraries.reject!{|library| library == current_user.library}
        format.html { render :action => "new" }
        format.xml  { render :xml => @inter_library_loan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inter_library_loans/1
  # PUT /inter_library_loans/1.xml
  def update
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @item = @inter_library_loan.item

    case @inter_library_loan.state
    when 'requested'
      @inter_library_loan.sm_ship!
    when 'shipped'
      @inter_library_loan.sm_receive!
    when 'received'
      @inter_library_loan.sm_return_ship!
    when 'return_shipped'
      @inter_library_loan.sm_return_receive!
    when 'return_received'
    end

    respond_to do |format|
      if @inter_library_loan.update_attributes(params[:inter_library_loan])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.inter_library_loan'))
        format.html { redirect_to(@inter_library_loan) }
        format.xml  { head :ok }
      else
        @inter_library_loan.item = @item
        @libraries = LibraryGroup.first.real_libraries
        @libraries.reject!{|library| library == current_user.library}
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inter_library_loan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inter_library_loans/1
  # DELETE /inter_library_loans/1.xml
  def destroy
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @inter_library_loan.destroy

    respond_to do |format|
      if @item
        format.html { redirect_to item_inter_library_loans_url(@item) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(inter_library_loans_url) }
        format.xml  { head :ok }
      end
    end
  end
 
  def export_loan_lists
    @libraries = Library.all
  end

  def get_loan_lists
    library_ids = params[:library] || []
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/inter_library_loans/loan_list"
 
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      library_ids.each do |library_id|
        library = Library.find(library_id) rescue nil
        to_libraries = InterLibraryLoan.joins(:item => :shelf).where(['shelves.id IN (?) AND inter_library_loans.reason = ? ', library.shelf_ids, 1]).inject([]){|libraries, data| libraries << data.borrowing_library}
        to_libraries << InterLibraryLoan.where(['borrowing_library_id = ? AND inter_library_loans.reason = ? ', library.id, 2]).inject([]){|libraries, data| libraries << Library.find(:first, :conditions => ['name = ? ', data.item.library])}
        to_libraries.flatten.each do |to_library|
          report.start_new_page
          report.page.item(:date).value(Time.now)
          report.page.item(:library).value(library.display_name.localize)
          report.page.item(:library_move_to).value(to_library.display_name.localize)

          @loans_checkouts = InterLibraryLoan.joins(:item => :shelf).where(['shelves.id IN (?) AND inter_library_loans.borrowing_library_id = ? AND inter_library_loans.reason = ?', library.shelf_ids, to_library.id, 1]).order('shelves.id')
          @loans_checkouts.each do |loan|
            report.page.list(:list).add_row do |row|
              row.item(:reason).value(t('inter_library_loan.checkout'))
              row.item(:item_identifier).value(loan.item.item_identifier)
              row.item(:shelf).value(loan.item.shelf.display_name) if loan.item.shelf
              row.item(:call_number).value(loan.item.call_number)
              row.item(:title).value(loan.item.manifestation.original_title) if loan.item.manifestation
            end
          end
          @loans_checkins = InterLibraryLoan.joins(:item => :shelf).where(['inter_library_loans.borrowing_library_id = ? AND shelves.id IN (?) AND inter_library_loans.reason = ?', library.id, to_library.shelf_ids, 2]).order('shelves.id')
          @loans_checkins.each do |loan|
            report.page.list(:list).add_row do |row|
              row.item(:reason).value(t('inter_library_loan.checkin'))
              row.item(:item_identifier).value(loan.item.item_identifier)
              row.item(:shelf).value(loan.item.shelf.display_name) if loan.item.shelf
              row.item(:call_number).value(loan.item.call_number)
              row.item(:title).value(loan.item.manifestation.original_title) if loan.item.manifestation
            end
          end
        end
      end

      send_data report.generate, :filename => "loan_lists.pdf", :type => 'application/pdf', :disposition => 'attachment'
      logger.error "created report: #{Time.now}"
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def pickup_item
    library = current_user.library
    item_identifier = params[:item_identifier].strip
    @pickup_item = Item.where(:item_identifier => item_identifier).first
    @loan = InterLibraryLoan.in_process.find(:first, :conditions => ['item_id = ?', @pickup_item.id])
    begin
      # pick up item
      @pickup_item.circulation_status = CirculationStatus.find(:first, :conditions => ['name = ?', "In Transit Between Library Locations"])  
      @pickup_item.save
      @loan.shipped_at = Time.zone.now
      @loan.sm_ship!
      @loan.save

      # export receipt for transportation
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/inter_library_loans/move_item"
      report.start_new_page
      report.page.item(:title).value(@pickup_item.manifestation.original_title)
      report.page.item(:call_number).value(@pickup_item.call_number)
      report.page.item(:from_library).value(@pickup_item.shelf.library.display_name.localize)
      
      send_data report.generate, :filename => "loan_item_#{@pickup_item.item_identifier}.pdf", :type => 'application/pdf', :disposition => 'attachment'
      logger.error "created report: #{Time.now}"
      return true
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def accept
  end

  def accept_item
    return nil unless request.xhr?
    begin 
      library = current_user.library
      item_identifier = params[:item_identifier]
      @item = Item.where(:item_identifier => item_identifier).first
      @loan = InterLibraryLoan.in_process.find(:first, :conditions => ['item_id = ? AND received_at IS NULL', @item.id]) if @item
      if @item.nil? || @loan.nil?
        render :json => {:error => t('inter_library_loan.no_loan')}
        return false
      end
      unless (@loan.reason == 1 && @loan.borrowing_library_id == library.id) || (@loan.reason == 2 && @item.shelf.library.id == library.id)
        render :json => {:error => t('inter_library_loan.wrong_library')}
        return false
      end
      InterLibraryLoan.transaction do
        @reserve = Reserve.waiting.find(:first, :conditions => ["item_id = ? AND state = ? AND receipt_library_id = ?", @item.id, "in_process", library.id])
        if @reserve
          @reserve.sm_retain!
        else
          @item.checkin!
        end
        @loan.received_at = Time.zone.now
        @loan.sm_receive!
        @loan.save
      end
      if @item
        html = render_to_string :partial => "accept_item"
        render :json => {:success => 1, :html => html}
      end
    rescue Exception => e
      logger.error "Failed to accept item: #{e}"
    end
  end

end
