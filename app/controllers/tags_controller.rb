class TagsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_if_nil
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  def index
    session[:params] ={} unless session[:params]
    session[:params][:tag] = params

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'name'
      sort[:sort_by] = 'name'
    when 'taggings_count'
      sort[:sort_by] = 'taggings_count'
    end
    sort[:order] = 'asc' if params[:order] == 'asc'

    query = @query = params[:query].to_s.strip
    page = params[:page] || 1

    @tags = Tag.search do
      fulltext query if query.present?
      paginate :page => page.to_i, :per_page => Tag.per_page
      order_by sort[:sort_by], sort[:order]
    end.results

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
      format.rss
      format.atom
    end
  end

  def show
    #@tag = Tag.find(params[:id])
    raise ActiveRecord::RecordNotFound if @tag.blank?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def edit
    #@tag = Tag.find(params[:id])
  end

  def update
    #@tag = Tag.find(params[:id])
  
    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.tag'))
        format.html { redirect_to tag_url(@tag.name) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors.to_xml }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    #@tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
