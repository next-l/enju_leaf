class ThemesController < InheritedResources::Base
  
  add_breadcrumb "I18n.t('activerecord.models.theme')", 'themes_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.theme'))", 'new_theme_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.theme'))", 'edit_theme_path(params[:id])', :only => [:edit, :update]
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    query = params[:query].to_s.strip
    @query = query.dup
    query = "#{query}*" if query.size == 1
    page = params[:page] || 1

    @themes = Theme.search do
     # fulltext query if query
      with(:publish).equal_to 0 #.to_i unless current_user.has_role?("Libralian")
      paginate :page => page.to_i, :per_page => Theme.default_per_page
    end.results
  end

=begin
  def show
    if params[:id]
      theme = Theme.find(params[:id])
      return
    end

    search = Sunspot.new_search(Manifestation)
    theme = @theme
    search.build do
      with(:theme_ids).equal_to theme.id if theme
    end
    page = params[:work_page] || 1
    search.query.paginate(page.to_i, Manifestation.default_per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @theme }
    end
  end
=end

  def update
    @theme = Theme.find(params[:id])
    if params[:move]
      move_position(@theme, params[:move])
      return
    end
    update!
  end
end
