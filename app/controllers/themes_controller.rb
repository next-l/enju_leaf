class ThemesController < InheritedResources::Base
  
  add_breadcrumb "I18n.t('activerecord.models.theme')", 'themes_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.theme'))", 'new_theme_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.theme'))", 'edit_theme_path(params[:id])', :only => [:edit, :update]
  respond_to :html, :json
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @theme = Theme.find(params[:id])
      if params[:move]
      move_position(@theme, params[:move])
      return
      end
    update!
  end
end
