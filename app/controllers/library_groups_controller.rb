class LibraryGroupsController < ApplicationController
  before_action :set_library_group, only: [ :show, :edit, :update ]
  before_action :check_policy, only: [ :index ]

  # GET /library_groups
  # GET /library_groups.json
  def index
    @library_groups = LibraryGroup.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /library_groups/1
  # GET /library_groups/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @library_group }
    end
  end

  # GET /library_groups/1/edit
  def edit
    @countries = Country.order(:position)
  end

  # PUT /library_groups/1
  # PUT /library_groups/1.json
  def update
    respond_to do |format|
      if @library_group.update(library_group_params)
        if @library_group.delete_header_logo == "1"
          @library_group.header_logo.destroy
        end

        format.html { redirect_to @library_group, notice: t("controller.successfully_updated", model: t("activerecord.models.library_group")) }
        format.json { head :no_content }
      else
        @countries = Country.order(:position)
        format.html { render action: "edit" }
        format.json { render json: @library_group.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_library_group
    @library_group = LibraryGroup.find(params[:id])
    if request.format == :download
      authorize @library_group, :show_logo?
    else
      authorize @library_group
    end
  end

  def check_policy
    authorize LibraryGroup
  end

  def library_group_params
    params.require(:library_group).permit(
      :name, :display_name, :short_name, :my_networks,
      :login_banner, :note, :country_id, :admin_networks, :url,
      :max_number_of_results, :footer_banner, :email,
      :book_jacket_source, :screenshot_generator,
      :header_logo, :delete_header_logo,
      :allow_bookmark_external_url, # EnjuBookmark
      {
        colors_attributes: [ :id, :property, :code ]
      },
      {
        user_attributes: [ :email ]
      },
      *LibraryGroup.globalize_attribute_names
    )
  end
end
