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
   
    unless current_user.try(:has_role?, 'Librarian')
      @themes = Theme.search do
        fulltext query if query
        with :publish, 0
        order_by :position
        paginate :page => page.to_i, :per_page => Theme.default_per_page
      end.results
    else
      unless query.blank?
        @themes = Theme.search do
          fulltext query
          paginate :page => page.to_i, :per_page => Theme.default_per_page
        end.results
      else
        @themes = Theme.page(page)
      end
    end
  end

  def show
    @themes = Theme.find(params[:id]).manifestations.scoped.page params[:page]
  end

  def update
    @theme = Theme.find(params[:id])
    if params[:move]
      move_position(@theme, params[:move])
      return
    end
    update!
  end
end
