class FamiliesController < ApplicationController
  before_filter :check_client_ip_address
  before_filter :check_librarian
  load_and_authorize_resource

  def index
    @families = Family.all

    # output
    if params[:output_pdf]
      data = Family.output_familylist_pdf(@families)
      send_data data.generate, :filename => Setting.family_list_print_pdf.filename
    end
    if params[:output_tsv]
      data = Family.output_familylist_tsv(@families)
      send_data data, :filename => Setting.family_list_print_tsv.filename
    end
  end

  def show
    @family = Family.find(params[:id])
  end

  def new
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    user_list(params)
    @family = Family.new
  end

  def create
    @family = Family.new(params[:family])
    respond_to do |format|
      begin
        ActiveRecord::Base.transaction do
          if @family.save
            @family.add_user(params[:family_users])                      
            flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.family'))
            format.html { redirect_to(@family) }
            format.json { render :json => @family, :status => :created, :location => @family }
          else
            user_list(params)
            format.html { render :action => "new" }
            format.json { render :json => @family.errors, :status => :unprocessable_entity }
          end
        end
      rescue
        user_list(params)
        format.html { render :action => "new" }
        format.json { render :json => @family.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def edit
    user_list(params)
    @family = Family.find(params[:id])
    @already_family_users = @family.users
  end

  def update
    @family = Family.find(params[:id])
    respond_to do |format|
    begin 
      ActiveRecord::Base.transaction do
        family_users = @family.family_users
        family_users.each do |user|
          user.destroy
        end
        @family.add_user(params[:family_users])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.family'))
        format.html { redirect_to(@family) }
        format.json { render :json => @family, :status => :created, :location => @family }
      end
    rescue Exception => e
      user_list(params)
      @already_family_users = @family.users
      format.html { render :action => "edit" }
      format.json { render :json => @family.errors, :status => :unprocessable_entity }
    end
    end
  end

  def destroy
    @family = Family.find(params[:id])
    family_users = @family.family_users
    family_users.each do |family_user|
      family_user.destroy
    end
    @family.destroy

    respond_to do |format|    
      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.family'))
      format.html { redirect_to families_path }
    end
  end

  def search_user
    user_list(params)
  end

private
  def user_list(params)
    query = params[:query].to_s
    @query = query.dup
    @count = {}
    
    query = params[:query].gsub("-", "") if params[:query]
    if query.size == 1
      query = "#{query}*"
    end

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    when 'telephone_number_1'
      sort[:sort_by] = 'telephone_number'
    when 'full_name'
      sort[:sort_by] = 'full_name'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role
    @date_of_birth = params[:birth_date].to_s.dup
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    flash[:message] = nil
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:message] = t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
    address = params[:address]
    @address = address

    query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text:#{address}" unless address.blank?

    # TODO need refactoring
    exclude_ids = []
    family_users = FamilyUser.all
    family_users.each do |family_user|
      exclude_ids << family_user.user_id
    end

    logger.info "family=#{exclude_ids.join(' ')}"

    s = "" 
    unless exclude_ids.empty?
      exclude_ids.each do |x| 
        s.concat(" id_i:#{x} OR") 
      end
      s.chomp!("OR")
      query = "#{query} NOT (#{s})"
    end

    logger.info "query:#{query}"

    @users = User.search do
      fulltext query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than role.id
    end.results

    @count[:query_result] = @users.total_entries
  end

end
