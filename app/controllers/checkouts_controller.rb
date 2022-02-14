class CheckoutsController < ApplicationController
  before_action :set_checkout, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create, :remove_all]
  before_action :get_user, only: [:index, :remove_all]
  before_action :get_item, only: :index
  after_action :convert_charset, only: :index

  # GET /checkouts
  # GET /checkouts.json
  def index
    if params[:icalendar_token].present?
      icalendar_user = Profile.where(checkout_icalendar_token: params[:icalendar_token]).first.try(:user)
      if icalendar_user.blank?
        raise ActiveRecord::RecordNotFound
      else
        @checkouts = icalendar_user.checkouts.not_returned.order('checkouts.id DESC')
      end
    else
      unless current_user
        access_denied
        return
      end
    end

    if ['text', 'rss'].include?(params[:format].to_s.downcase)
      per_page = 500
      page = 1
    else
      per_page = Checkout.default_per_page
      page = params[:page] || 1
    end

    unless icalendar_user
      search = Checkout.search
      if @user
        user = @user
        if current_user.try(:has_role?, 'Librarian')
          search.build do
            with(:username).equal_to user.username
          end
        elsif current_user == user
          redirect_to checkouts_url(format: params[:format])
          return
        else
          access_denied
          return
        end
      else
        unless current_user.try(:has_role?, 'Librarian')
          search.build do
            with(:username).equal_to current_user.username
            unless current_user.profile.save_checkout_history?
              with(:checked_in_at).equal_to nil
            end
          end
        end
      end

      if @item
        item = @item
        search.build do
          with(:item_identifier).equal_to item.item_identifier
        end
      end

      if params[:days_overdue].present?
        days_overdue = params[:days_overdue].to_i
        date = days_overdue.days.ago.beginning_of_day
        search.build do
          with(:due_date).less_than date
          with(:checked_in_at).equal_to nil
        end
      end

      if params[:reserved].present?
        if params[:reserved] == 'true'
          @reserved = reserved = true
        elsif params[:reserved] == 'false'
          @reserved = reserved = false
        end
        search.build do
          with(:reserved).equal_to reserved
        end
      end

      search.build do
        order_by :created_at, :desc
        facet :reserved
      end
      search.query.paginate(page.to_i, per_page)
      @checkouts = search.execute!.results
      @checkouts_facet = search.facet(:reserved).rows
    end

    @days_overdue = days_overdue if days_overdue

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @checkouts }
      format.rss  { render layout: false }
      format.ics
      format.text
      format.atom
    end
  end

  # GET /checkouts/1
  # GET /checkouts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @checkout }
    end
  end

  # GET /checkouts/1/edit
  def edit
    @new_due_date = @checkout.get_new_due_date
  end

  # PUT /checkouts/1
  # PUT /checkouts/1.json
  def update
    @checkout.assign_attributes(checkout_params)
    @checkout.checkout_renewal_count += 1

    respond_to do |format|
      if @checkout.save
        format.html { redirect_to @checkout, notice: t('controller.successfully_updated', model: t('activerecord.models.checkout')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkouts/1
  # DELETE /checkouts/1.json
  def destroy
    user = @checkout.user
    @checkout.operator = current_user
    @checkout.user_id = nil
    @checkout.save!

    respond_to do |format|
      format.html { redirect_to checkouts_url(user_id: user.username), notice: t('controller.successfully_deleted', model: t('activerecord.models.checkout')) }
      format.json { head :no_content }
    end
  end

  def remove_all
    if @user
      unless current_user.has_role?('Librarian')
        if @user != current_user
          access_denied
          return
        end
      end
      Checkout.remove_all_history(@user)
    end

    respond_to do |format|
      format.html { redirect_to checkouts_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.checkout')) }
      format.json { head :no_content }
    end
  end

  private

  def set_checkout
    @checkout = Checkout.find(params[:id])
    authorize @checkout
  end

  def check_policy
    authorize Checkout
  end

  def checkout_params
    params.fetch(:checkout, {}).permit(:due_date)
  end

  def filtered_params
    params.permit([:user_id, :days_overdue, :reserved])
  end

  helper_method :filtered_params
end
