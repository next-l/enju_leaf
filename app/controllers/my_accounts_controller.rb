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

    respond_to do |format|
      format.html
      format.xml {render :xml => @user}
    end
  end

  def edit
    @user = current_user
    @user.role_id = @user.role.id
    @roles = Role.all
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update_with_password(params[:user])
        sign_in(@user, :bypass => true)
        @user.role = Role.where(:id => @user.role_id).first if @user.role_id
        format.html { redirect_to(my_account_url, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user'))) }
        format.xml  { head :ok }
      else
        @roles = Role.all
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(root_url, :notice => 'devise.registrations.destroyed') }
      format.xml  { head :ok }
    end
  end
end
