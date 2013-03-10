class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user

    if params[:filename]
      find_and_send_user_file
      return
    end

    session[:user_return_to] = nil
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end
    #TODO
    if defined?(EnjuBookmark) 
      @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
    end
    if defined?(EnjuEvent) 
      @events = Event.order('start_at DESC').limit(5)
    end
    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil
    prepare_options
    
    # 資料区分
    get_manifestation_types
    
    respond_to do |format|
      if defined?(EnjuCustomize)
        format.html { render :file => "page/#{EnjuCustomize.render_dir}/index", :layout => EnjuCustomize.render_layout}
      else
        format.html
      end
      format.json { render :json => @user }
    end
  end

  def edit
    @user = current_user
    @user.role_id = @user.role.id
    prepare_options

    render :template => 'opac/my_accounts/edit', :layout => 'opac' if params[:opac]
  end

  def update
    @user = current_user

    respond_to do |format|
=begin
      if current_user.has_role?('Librarian')
        saved = current_user.update_with_password(params[:user], :as => :admin)
      else
        saved = current_user.update_with_password(params[:user])
      end
=end
#      if saved
      begin
        # update patron
        if params[:opac]
          @user.patron.update_attributes!(params[:patron])
          @user.patron.email = params[:user][:email] if params[:user] and params[:user][:email]
          @user.patron.save!
        end
  
        # update user
        if current_user.has_role?('Librarian')
          saved = current_user.update_with_password(params[:user], :as => :admin)
        else
          saved = current_user.update_with_password(params[:user])
        end
        raise unless saved
        sign_in(current_user, :bypass => true)
        if params[:opac]
          format.html { redirect_to opac_path, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        end
        format.html { redirect_to my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        format.json { head :no_content }
#      else
      rescue 
        @user = current_user
        if params[:opac] and @user.patron.errors
          @user.patron.errors.each do |attr, msg|
            @user.errors.add(attr, msg)
          end
        end
        prepare_options
        format.html { render :action => "edit", :template => 'opac/my_accounts/edit', :layout => 'opac' } if params[:opac]
        format.html { render :action => "edit" }
        format.json { render :json => current_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => 'devise.registrations.destroyed') }
      format.json { head :no_content }
    end
  end

  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all
    @languages = Language.all_cache
    if current_user.active_for_authentication?
      current_user.locked = '0'
    else
      current_user.locked = '1'
    end
    @departments = Department.all
  end

  private

    def find_and_send_user_file
      category = params[:category].try(:to_sym)
      unless category && params[:random]
        render nothing: true, status: :not_found
        return
      end

      filename = params[:filename]
      paths = UserFile.new(@user).find(category, filename, params[:random])
      @user_file = paths.last

      unless @user_file
        render nothing: true, status: :not_found
        return
      end

      extname = File.extname(filename).sub(/\A\./, '') # "foo.pdf" #=> "pdf"
      mime_type = Mime::Type.lookup_by_extension(extname) || Mime::Type.lookup('application/octet-stream')

      if force_mime_type = UserFile.category[category][:mime_type]
        mime_type = force_mime_type
      end

      filename = ERB::Util.url_encode(filename)
      send_file @user_file,
        filename: filename,
        type: mime_type
    end
end
