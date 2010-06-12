class LendingPoliciesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_group, :get_item
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /lending_policies
  # GET /lending_policies.xml
  def index
    if @item
      @lending_policies = @item.lending_policies.paginate(:page => params[:page])
    else
      @lending_policies = LendingPolicy.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lending_policies }
    end
  end

  # GET /lending_policies/1
  # GET /lending_policies/1.xml
  def show
    @lending_policy = LendingPolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lending_policy }
    end
  end

  # GET /lending_policies/new
  # GET /lending_policies/new.xml
  def new
    @lending_policy = LendingPolicy.new
    @lending_policy.item = @item

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lending_policy }
    end
  end

  # GET /lending_policies/1/edit
  def edit
    @lending_policy = LendingPolicy.find(params[:id])
  end

  # POST /lending_policies
  # POST /lending_policies.xml
  def create
    @lending_policy = LendingPolicy.new(params[:lending_policy])

    respond_to do |format|
      if @lending_policy.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.lending_policy'))
        format.html { redirect_to(@lending_policy) }
        format.xml  { render :xml => @lending_policy, :status => :created, :location => @lending_policy }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @lending_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lending_policies/1
  # PUT /lending_policies/1.xml
  def update
    @lending_policy = LendingPolicy.find(params[:id])

    respond_to do |format|
      if @lending_policy.update_attributes(params[:lending_policy])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.lending_policy'))
        format.html { redirect_to(@lending_policy) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lending_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lending_policies/1
  # DELETE /lending_policies/1.xml
  def destroy
    @lending_policy = LendingPolicy.find(params[:id])
    @lending_policy.destroy

    respond_to do |format|
      format.html { redirect_to(lending_policies_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @user_groups = UserGroup.all(:order => :position)
  end
end
