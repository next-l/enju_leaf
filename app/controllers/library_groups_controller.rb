class LibraryGroupsController < ApplicationController
  before_action :set_library_group, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /library_groups
  def index
    @library_groups = LibraryGroup.all
  end

  # GET /library_groups/1
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.download {
        if @library_group.header_logo.exists?
          if ENV['ENJU_STORAGE'] == 's3'
            file = Faraday.get(@library_group.header_logo.expiring_url(3600, :medium)).body.force_encoding('UTF-8')
            send_data file, filename: File.basename(@library_group.header_logo_file_name), type: @library_group.header_logo_content_type, disposition: :inline
          else
            file = File.expand_path(@library_group.header_logo.path(:medium))
            if File.exist?(file) && File.file?(file)
              send_file file, filename: File.basename(@library_group.header_logo_file_name), type: @library_group.header_logo_content_type, disposition: :inline
            end
          end
        end
      }
    end
  end

  # GET /library_groups/1/edit
  def edit
    @countries = Country.order(:position)
  end

  # PUT /library_groups/1
  def update
    respond_to do |format|
      if @library_group.update(library_group_params)
        if @library_group.delete_header_logo == '1'
          @library_group.header_logo.destroy
        end

        format.html { redirect_to @library_group, notice: t('controller.successfully_updated', model: t('activerecord.models.library_group')) }
      else
        @countries = Country.order(:position)
        format.html { render action: "edit" }
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
      :book_jacket_source, :screenshot_generator, :erms_url,
      :header_logo, :delete_header_logo,
      :allow_bookmark_external_url, # EnjuBookmark
      {
        colors_attributes: [:id, :property, :code]
      },
      {
        user_attributes: [:email]
      },
      *LibraryGroup.globalize_attribute_names
    )
  end
end
