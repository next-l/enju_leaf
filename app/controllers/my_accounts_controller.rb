class MyAccountsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @user = current_user
    session[:user_return_to] = nil
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end
    @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil
    prepare_options

    respond_to do |format|
      format.html
      format.xml {render :xml => @user}
    end
  end

  def edit
    @user = current_user
    @user.role_id = @user.role.id
    prepare_options
  end

  def update
    #current_user.update_with_params(params[:user])
    current_user.update_attributes(params[:user])
    current_user.operator = current_user
    @user = current_user

    respond_to do |format|
      if current_user.update_with_password(params[:user])
        sign_in(current_user, :bypass => true)
        format.html { redirect_to(my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user'))) }
        format.json { head :no_content }
      else
        prepare_options
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
