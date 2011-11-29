# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  #before_filter :reset_params_session
  load_and_authorize_resource :except => [:search_family, :get_family_info, :output_password, :edit_user_number, :update_user_number]
  helper_method :get_patron
  before_filter :store_location, :only => [:index]
  before_filter :clear_search_sessions, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :user_sweeper, :only => [:create, :update, :destroy]
  #ssl_required :new, :edit, :create, :update, :destroy
  ssl_allowed :index, :show, :new, :edit, :create, :update, :destroy, :search_family, :get_family_info, :output_password

  def index
    query = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    when 'telephone_number_1'
      sort[:sort_by] = 'patrons.telephone_number_1'
    when 'full_name'
      sort[:sort_by] = 'patrons.full_name_transcription'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = params[:query].gsub("-", "") if params[:query]
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

    query = "#{query} date_of_birth_d: [#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text: #{address}" unless address.blank?

    logger.error "query #{query}"
    logger.error flash[:message]

    unless query.blank?
      @users = User.search do
        fulltext query
        order_by sort[:sort_by], sort[:order]
        with(:required_role_id).less_than role.id
      end.results
    else
      if sort[:sort_by] == 'patrons.telephone_number_1'|| sort[:sort_by] == 'patrons.full_name_transcription' 
        @users = User.joins(:patron).order("#{sort[:sort_by]} #{sort[:order]}").page(page)
      else
        @users = User.order("#{sort[:sort_by]} #{sort[:order]}").page(page)
      end
    end
    @count[:query_result] = @users.total_entries

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users }
    end
  end

  def show
    #if @user == current_user
    #  redirect_to my_account_url
    #  return
    #end
    unless @user == current_user or current_user.has_role?('Librarian')
      access_denied; return
    end 
    session[:user_return_to] = nil
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end

    @patron = @user.patron
    @telephone_number_1_type = set_phone_type(@user.patron.telephone_number_1_type_id)
    @extelephone_number_1_type = set_phone_type(@user.patron.extelephone_number_1_type_id)
    @fax_number_1_type = set_phone_type(@user.patron.fax_number_1_type_id)
    @telephone_number_2_type = set_phone_type(@user.patron.telephone_number_2_type_id)
    @extelephone_number_2_type = set_phone_type(@user.patron.extelephone_number_2_type_id)
    @fax_number_2_type = set_phone_type(@user.patron.fax_number_2_type_id)

    #@tags = @user.owned_tags_by_solr
    @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse

    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil

    @checkout_user = @user
    family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @user.id]).family_id rescue nil
    if family_id
      @family_users = Family.find(family_id).users
      @family_users.delete_if{|user| user == @user}
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user }
    end
  end

  def new
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @family_with = User.find(params[:user]) if params[:user]
    if @family_with
      @user = @family_with.clone rescue User.new
      @user.username = nil
      @user.user_number = nil
      @user.role_id = @family_with.role.id
      @patron = @family_with.patron.clone rescue Patron.new
      @patron.full_name = nil
      @patron.full_name_transcription = nil
      @family_id = FamilyUser.find(:first, :conditions => ['user_id=?',  params[:user]]).family_id rescue nil
      @patron.note_update_at = nil
      @patron.note_update_by = nil
      @patron.note_update_library = nil
      @family = @family_with.id
    else 
      @user = User.new
      @user.library = current_user.library
      @user.locale = current_user.locale
      @user.role_id = Role.where(:name => 'User').first.id
      @user.required_role_id = Role.where(:name => 'Librarian').first.id
      @patron = Patron.new
      @patron.required_role = Role.find_by_name('Librarian')
      @patron.language = Language.where(:iso_639_1 => I18n.default_locale.to_s).first || Language.first 
      @patron.country = current_user.library.country if current_user.library
      @patron.country_id = LibraryGroup.site_config.country_id
      @patron.telephone_number_1_type_id = 1
      @patron.telephone_number_2_type_id = 1
      @patron.extelephone_number_1_type_id = 2
      @patron.extelephone_number_2_type_id = 2
      @patron.fax_number_1_type_id = 3
      @patron.fax_number_2_type_id = 3
      @family = 0
    end
    #@user.openid_identifier = flash[:openid_identifier]
    prepare_options
    @user_groups = UserGroup.all
#    get_patron
#    if @patron.try(:user)
#      flash[:notice] = t('page.already_activated')
#      redirect_to @patron
#      return
#    end
    @user.patron_id = @patron.id if @patron
    logger.error "2: #{@patron.id}"
  end

  def edit
    @user.role_id = @user.role.id
    @patron = @user.patron
    family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @user.id]).family_id rescue nil
    if family_id
      @family_users = Family.find(family_id).users
    end
    #@note_last_updateed_user = User.find(@patron.note_update_by) rescue nil
    if params[:mode] == 'feed_token'
      if params[:disable] == 'true'
        @user.delete_checkout_icalendar_token
      else
        @user.reset_checkout_icalendar_token
      end
      render :partial => 'users/feed_token'
      return
    end
    prepare_options
  end

  def create
    respond_to do |format|
    begin
      Patron.transaction do
        @family = params[:family]
        @user = User.create_with_params(params[:user], params[:has_role_id])
        @user.set_auto_generated_password
        @patron = Patron.create_with_user(params[:patron], @user)

        logger.info @patron
        logger.info @user

        @patron.save!
        @user.patron = @patron
        @user.set_family(@family) unless @family.blank?
        @user.save!
        flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
        flash[:temporary_password] = @user.password
        format.html { redirect_to user_url(@user) }
        #format.html { redirect_to new_user_patron_url(@user) }
        format.xml  { head :ok }
      end
    rescue ActiveRecord::RecordInvalid
      prepare_options
      @patron.errors.each do |attr, msg|
        @user.errors.add(attr, msg)
      end 
#      flash[:error] = t('user.could_not_setup_account')
      format.html { render :action => "new" }
      format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
    rescue Exception => e
      logger.error e
    end
    end
  end

  def update
    respond_to do |format|
    begin
      @family = params[:family]
      @user.update_with_params(params[:user])
      if params[:user][:auto_generated_password] == "1"
        @user.set_auto_generated_password
        flash[:temporary_password] = @user.password
      end

      if current_user.has_role?('Administrator')
        if @user.role_id
          role = Role.find(@user.role_id)
          @user.role = role
        end
      end
 
      @user.patron.update_attributes(params[:patron])
      @user.patron.email = params[:user][:email]
      @user.patron.language = Language.find(:first, :conditions => ['iso_639_1=?', params[:user][:locale]]) rescue nil
      @user.patron.save!

      #@user.save do |result|
      @user.out_of_family if params[:out_of_family] == "1"
      unless params[:family].blank?
        @user.set_family(params[:family])
      end
      @user.save!
      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user'))
      format.html { redirect_to user_url(@user) }
      format.xml  { head :ok }
    rescue # ActiveRecord::RecordInvalid
      @patron = @user.patron  
      @patron.errors.each do |attr, msg|
        @user.errors.add(attr, msg)
      end  
      family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @user.id]).family_id rescue nil
      if family_id
        @family_users = Family.find(family_id).users
      end
      prepare_options
      format.html { render :action => "edit" }
      format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
    end
    end
  end

  def destroy
    if @user.deletable_by(current_user)
      @user.destroy
    else
      flash[:notice] = @user.errors[:base].join(' ')
      redirect_to current_user
      return
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def edit_user_number
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.find_by_username(params[:id])
  end

  def update_user_number
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.find_by_username(params[:id])
    #@user.user_number = params[:new_user_number]
    debugger
    begin 
      @user.update_attributes({:user_number => params[:new_user_number]})
      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user.user_number'))
      redirect_to(users_url)       
    rescue # ActiveRecord::RecordInvalid
      #@user = User.find_by_username(params[:id])
      render :action => :edit_user_number 
    end
  end

  def output_password
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'password.tlf')
    report.start_new_page do |page|
      page.item(:password).value(params[:password])
    end
    send_data report.generate, :filename => "password.pdf", :type => 'application/pdf', :disposition => 'attachment'
  end

  def search_family
    return nil unless request.xhr?
    unless params[:keys].blank?
      tel_1 = params[:keys][:tel_1]
      tel_1.delete!("-")
      @user = User.find(params[:user]) rescue nil
      @family = params[:family]
      @family_id = FamilyUser.find(:first, :conditions => ['user_id=?', @user.id]).family_id rescue nil
      query = <<-SQL
        SELECT users.id, users.username
        FROM users left join patrons 
         ON patrons.user_id = users.id 
         WHERE translate(patrons.telephone_number_1, '-', '') = :tel_1
         AND patrons.last_name = :last_name
         AND patrons.address_1 = :address_1
      SQL
      query_params = {:tel_1=>tel_1, :last_name=>params[:keys][:last_name], :address_1=>params[:keys][:address_1]}
      @users = User.find_by_sql([query, query_params]) rescue nil
      all_user_ids = []
      if @users
        #logger.info @users
        @users.each do |user|
          #logger.info "user.id=#{user.id}"
          all_user_ids << user.id
        end
      end
      family_users = FamilyUser.find(:all, :conditions => ['user_id IN (?)', all_user_ids])
      family_user_ids = []
      @families = []
      family_users.each do |f_user|
        family_user_ids << f_user.user_id
        @families << Family.find(f_user.family_id)
      end
      @families.uniq!
      already_family_users = Family.find(family_id).users if family_id rescue nil
      group_users = []
      if @families
        @families.each do |f|
          f.users.each do |u|
            group_users << u
          end
        end
      end
      @users.delete_if{|user| already_family_users.include?(user)} if already_family_users
      @users.delete_if{|user| group_users.include?(user)} if group_users

      #
      #logger.info("family=#{@family}")
      unless @family.empty?
        @families.each do |f|
          #logger.info enum_users_id(f.users)  
          u2 = f.users.select {|u| u.id.to_s == @family}
          unless u2.empty?
            f.users.reject! {|u| u.id.to_s == @family}
            f.users.unshift(u2.first)
            #logger.info enum_users_id(f.users)  
            break
          end
        end
      end

      unless @users.blank? && @families.blank?
        html = render_to_string :partial => "search_family"
        render :json => {:success => 1, :html => html}
      end
    end
  end

  def get_family_info
    return nil unless request.xhr?
    unless params[:user_id].blank?
      family_id = FamilyUser.where(:user_id => params[:user_id]).first.family_id rescue nil
      @user = User.find(FamilyUser.where(:family_id => family_id).order(:id).first.user_id) rescue nil
      if @user.nil?
        @user = User.find(params[:user_id]) rescue nil
      end
      @patron = @user.patron
      render :json => {:success => 1, :user => @user, :patron => @patron }
    end
  end

  private
  def enum_users_id(users)
    s = ""
    unless users.empty?
      users.each do |u|
        s.concat("#{u.id} ")
      end
    end
    return s
  end

  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all
    @languages = Language.all_cache
    @countries = Country.all_cache
    if @user.active_for_authentication?
      @user.locked = '0'
    else
      @user.locked = '1'
    end
    @patron_types = PatronType.all
  end

  def set_phone_type(phone_type_id)
    type = nil;
    if phone_type_id == 1
      type = '('+ t('activerecord.attributes.patron.home_phone') +')'
    elsif phone_type_id == 2
      type = '('+ t('activerecord.attributes.patron.fax') +')'
    elsif phone_type_id == 3
      type = '(' +t('activerecord.attributes.patron.mobile_phone') +')'
    elsif phone_type_id == 4
      type = '('+ t('activerecord.attributes.patron.company_phone') +')'
    end
    return type;
  end
end
