class KeywordCountsController < ApplicationController
  add_breadcrumb "I18n.t('activerecord.models.keyword_count')", 'keyword_counts_path', :only => [:index]
  load_and_authorize_resource

  def index
    @start_d = params[:start_d] ? params[:start_d] : (Date.today - 1.month).strftime("%Y-%m-%d")
    @end_d = params[:end_d] ? params[:end_d] : Date.today.strftime("%Y-%m-%d")
    @keyword_counts, flash[:message] = KeywordCount.create_ranks(@start_d, @end_d)
  end
end
