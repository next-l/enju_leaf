class InterLibraryLoansController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_item
  before_filter :store_page, :only => :index
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  # GET /inter_library_loans
  # GET /inter_library_loans.json
  def index
    @from_library = @to_library = Library.real.all
    @reasons = InterLibraryLoan.reasons
    @selected_from_library = @selected_to_library = Library.real.all.inject([]){|ids, library| ids << library.id}
    @selected_reason = InterLibraryLoan.reasons.inject([]){|ids, reason| ids << reason[1]}
    if params[:commit]
      @selected_from_library = params[:from_library] ? params[:from_library].inject([]){|ids, id| ids << id.to_i} : []
      @selected_to_library = params[:to_library] ? params[:to_library].inject([]){|ids, id| ids << id.to_i} : []
      @selected_reason = params[:reason] ? params[:reason].inject([]){|ids, id| ids << id.to_i} : []
    end
    from_library = @selected_from_library
    to_library = @selected_to_library
    reason = @selected_reason
    # check conditions
    flash[:notice] = t('item_list.no_list_condition') if @selected_from_library.blank? or @selected_to_library.blank? or @selected_reason.blank?

    # query
    query = params[:query].to_s.strip
    @query = query.dup
    query = "#{query}*" if query.size == 1

    page = params[:page] || 1
    if @item
      if @query.present?
        @inter_library_loans = @item.inter_library_loans.search do
          fulltext query
          with(:from_library_id, from_library_id)
          with(:to_library_id, to_library)
          with(:reason, reason)
          paginate :page => page.to_i, :per_page => InterLibraryLoan.default_per_page
        end.results
      else
        @inter_library_loans = @item.inter_library_loans.where(:from_library_id => @selected_from_library, :to_library_id => @selected_to_library, :reason => @selected_reason).page(page)
      end
    else
      if @query.present?
        @inter_library_loans = InterLibraryLoan.search do
          fulltext query
          with(:from_library_id, from_library)
          with(:to_library_id, to_library)
          with(:reason, reason) 
          #with(:reason).equal_to 2
          paginate :page => page.to_i, :per_page => InterLibraryLoan.default_per_page
        end.results
      else
        @inter_library_loans = InterLibraryLoan.where(:from_library_id => @selected_from_library, :to_library_id => @selected_to_library, :reason => @selected_reason).page(page)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @inter_library_loans }
      format.rss  { render :layout => false }
      format.atom
    end
  end

  # GET /inter_library_loans/1
  # GET /inter_library_loans/1.json
  def show
    @inter_library_loan = InterLibraryLoan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @inter_library_loan }
    end
  end

  # GET /inter_library_loans/new
  # GET /inter_library_loans/new.json
  def new
    @inter_library_loan = InterLibraryLoan.new
    @current_library = current_user.library
    @libraries = LibraryGroup.first.real_libraries
    @reasons = InterLibraryLoan.reasons
#    @libraries.reject!{|library| library == current_user.library}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @inter_library_loan }
    end
  end

  # GET /inter_library_loans/1/edit
  def edit
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @libraries = LibraryGroup.first.real_libraries
    @reasons = InterLibraryLoan.reasons
#    @libraries.reject!{|library| library == current_user.library}
  end

  # POST /inter_library_loans
  # POST /inter_library_loans.json
  def create
    @inter_library_loan = InterLibraryLoan.new(params[:inter_library_loan])
    item = Item.where(:item_identifier => params[:inter_library_loan][:item_identifier]).first
    @inter_library_loan.item = item

    respond_to do |format|
      if @inter_library_loan.save
        @inter_library_loan.sm_request!
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.inter_library_loan'))
        format.html { redirect_to(@inter_library_loan) }
        format.json { render :json => @inter_library_loan, :status => :created, :location => @inter_library_loan }
      else
        @current_library = @inter_library_loan.from_library
        @libraries = LibraryGroup.first.real_libraries
        @reasons = InterLibraryLoan.reasons
#        @libraries.reject!{|library| library == current_user.library}
        format.html { render :action => "new" }
        format.json { render :json => @inter_library_loan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inter_library_loans/1
  # PUT /inter_library_loans/1.json
  def update
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @item = @inter_library_loan.item

    respond_to do |format|
      if @inter_library_loan.update_attributes(params[:inter_library_loan])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.inter_library_loan'))
        format.html { redirect_to(@inter_library_loan) }
        format.json { head :no_content }
      else
        @inter_library_loan.item = @item
        @libraries = LibraryGroup.first.real_libraries
        @reasons = InterLibraryLoan.reasons
#        @libraries.reject!{|library| library == current_user.library}
        format.html { render :action => "edit" }
        format.json { render :json => @inter_library_loan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inter_library_loans/1
  # DELETE /inter_library_loans/1.json
  def destroy
    @inter_library_loan = InterLibraryLoan.find(params[:id])
    @inter_library_loan.destroy

    respond_to do |format|
      if @item
        format.html { redirect_to item_inter_library_loans_url(@item) }
        format.json { head :no_content }
      else
        format.html { redirect_to(inter_library_loans_url) }
        format.json { head :no_content }
      end
    end
  end
 
  def export_loan_lists
    @libraries = Library.real.all
    @selected_library = params[:library] || [current_user.library.id]
  end

  def get_loan_lists
    @selected_library = params[:library] || []

    # check checked
    if @selected_library.empty?
      flash[:message] = t('inter_library_loan.no_library')
      @libraries = Library.real.all
      render :export_loan_lists; return false
    end
    # check date_exist?
    @loans = InterLibraryLoan.loan_items
    if @loans.blank?
      flash[:message] = t('inter_library_loan.no_loan')
      @libraries = Library.real.all
      render :export_loan_lists; return false
    end

    begin
      report = InterLibraryLoan.get_loan_lists(@loans, @selected_library)
      if report.page
        send_data report.generate, :filename => "loan_lists.pdf", :type => 'application/pdf', :disposition => 'attachment'
        logger.error "created report: #{Time.now}"
        return true
      else
        flash[:message] = t('inter_library_loan.no_loan')
        @libraries = Library.real.all
        render :export_loan_lists; return false
      end
    rescue Exception => e
      logger.error "failed #{e}"
      @libraries = Library.real.all
      render :export_loan_lists; return false
    end
  end

  def pickup_item
    library = current_user.library
    item_identifier = params[:item_identifier_tmp].strip
    @pickup_item = Item.where(:item_identifier => item_identifier).first

    # check item_exist?
    unless @pickup_item
      flash[:message] = t('inter_library_loan.no_item') 
      render :pickup and return false
    end
    # check loan_item_exist?
    @loan = InterLibraryLoan.in_process.find(:first, :conditions => ['item_id = ?', @pickup_item.id])
    unless @loan
      flash[:message] = t('inter_library_loan.no_loan') 
      render :pickup and return false
    end

    begin
      # pick up item
      @pickup_item.circulation_status = CirculationStatus.find(:first, :conditions => ['name = ?', "In Transit Between Library Locations"])  
      @pickup_item.save
      @loan.shipped_at = Time.zone.now
      @loan.sm_ship!
      @loan.save

      report = InterLibraryLoan.get_pickup_item_file(@pickup_item, @loan)
      # check dir
      out_dir = "#{Rails.root}/private/system/inter_library_loans/"
      FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
      # make pdf
      pdf = "loan_item.pdf"
      report.generate_file(out_dir + pdf)

      flash[:message] = t('inter_library_loan.successfully_pickup', :item_identifier => item_identifier)
      flash[:path] = out_dir + pdf

      logger.error "created report: #{Time.now}"
      render :pickup
    rescue Exception => e
      logger.error "failed #{e}"
      flash[:message] = t('inter_library_loan.failed_pickup')
      render :pickup and return false
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
      unless @loan.to_library == current_user.library
        render :json => {:error => t('inter_library_loan.wrong_library')}
        return false
      end
      InterLibraryLoan.transaction do
        @reserve = Reserve.waiting.find(:first, :conditions => ["item_id = ? AND state = ? AND receipt_library_id = ?", @item.id, "in_process", library.id])
        if @reserve
          @reserve.sm_retain!
        else
          @item.checkin!
          @item.set_next_reservation
        end
        @loan.received_at = Time.zone.now
        @loan.sm_receive!
        @loan.save
      end
      if @item
        message = t('inter_library_loan.successfully_accept', :item_identifier => item_identifier)
        html = render_to_string :partial => "accept_item"
        render :json => {:success => 1, :html => html, :message => message}
      end
    rescue Exception => e
      logger.error "Failed to accept item: #{e}"
      render :json => {:error => t('inter_library_loan.failed_accept')}
    end
  end

  def download_file
    #TODO fullpath -> filename 
    path = params[:path]
    if File.exist?(path)
      #send_file path, :type => "application/pdf", :disposition => 'attachment'
      send_file path, :type => "application/pdf", :disposition => 'inline'
    else
      logger.warn "not exist file. path:#{path}"
      render :pickup and return
    end
  end

  def output
    @loan = InterLibraryLoan.find(params[:id])
    if @loan.nil?
      flash[:message] = t('inter_library_loan.no_loan') 
      return false
    end
    file = InterLibraryLoan.get_loan_report(@loan)
    send_data file, :filename => "loan.pdf", :type => 'application/pdf', :disposition => 'attachment'
  end
end
