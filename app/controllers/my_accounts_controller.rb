class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    session[:user_return_to] = nil
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end
    #TODO
    if defined?(EnjuBookmark) 
      @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
    end
    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil
    prepare_options

    respond_to do |format|
      format.html
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
      if current_user.has_role?('Librarian')
        saved = current_user.update_with_password(params[:user], :as => :admin)
      else
        saved = current_user.update_with_password(params[:user])
      end

      if saved
        sign_in(current_user, :bypass => true)
        format.html { redirect_to opac_path, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) } if params[:opac]
        format.html { redirect_to my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        format.json { head :no_content }
      else
        @user = current_user
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
  end
end
