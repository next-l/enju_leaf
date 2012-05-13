class PatronMergeListsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  # GET /patron_merge_lists
  # GET /patron_merge_lists.json
  def index
    @patron_merge_lists = PatronMergeList.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @patron_merge_lists }
    end
  end

  # GET /patron_merge_lists/1
  # GET /patron_merge_lists/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @patron_merge_list }
    end
  end

  # GET /patron_merge_lists/new
  # GET /patron_merge_lists/new.json
  def new
    @patron_merge_list = PatronMergeList.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @patron_merge_list }
    end
  end

  # GET /patron_merge_lists/1/edit
  def edit
  end

  # POST /patron_merge_lists
  # POST /patron_merge_lists.json
  def create
    @patron_merge_list = PatronMergeList.new(params[:patron_merge_list])

    respond_to do |format|
      if @patron_merge_list.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron_merge_list'))
        format.html { redirect_to(@patron_merge_list) }
        format.json { render :json => @patron_merge_list, :status => :created, :location => @patron_merge_list }
      else
        format.html { render :action => "new" }
        format.json { render :json => @patron_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patron_merge_lists/1
  # PUT /patron_merge_lists/1.json
  def update
    respond_to do |format|
      if @patron_merge_list.update_attributes(params[:patron_merge_list])
        if params[:mode] == 'merge'
          selected_patron = Patron.find(params[:selected_patron_id]) rescue nil
          if selected_patron
            @patron_merge_list.merge_patrons(selected_patron)
            flash[:notice] = t('merge_list.successfully_merged', :model => t('activerecord.models.patron'))
          else
            flash[:notice] = t('merge_list.specify_id', :model => t('activerecord.models.patron'))
            redirect_to patron_merge_list_url(@patron_merge_list)
            return
          end
        else
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron_merge_list'))
        end
        format.html { redirect_to(@patron_merge_list) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @patron_merge_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patron_merge_lists/1
  # DELETE /patron_merge_lists/1.json
  def destroy
    @patron_merge_list.destroy

    respond_to do |format|
      format.html { redirect_to(patron_merge_lists_url) }
      format.json { head :no_content }
    end
  end
end
