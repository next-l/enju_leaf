# -*- encoding: utf-8 -*-
class BookmarksController < ApplicationController
  before_filter :store_location
  load_and_authorize_resource
  before_filter :get_user, :only => :new
  before_filter :get_user_if_nil, :except => :new
  before_filter :check_user, :only => :index
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :bookmark_sweeper, :only => [:create, :update, :destroy]

  # GET /bookmarks
  # GET /bookmarks.xml
  def index
    search = Bookmark.search(:include => [:manifestation])
    query = params[:query].to_s.strip
    unless query.blank?
      @query = query.dup
    end
    user = @user
    search.build do
      fulltext query
      order_by(:created_at, :desc)
      with(:user_id).equal_to user.id if user
    end
    page = params[:page] || 1
    flash[:page] = page if page >= 1
    search.query.paginate(page.to_i, Bookmark.per_page)
    @bookmarks = search.execute!.results

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @bookmarks }
    end
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.xml
  def show
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @bookmark }
    end
  end

  # GET /bookmarks/new
  def new
    unless current_user == @user
      access_denied
      return
    end
    @bookmark = Bookmark.new(params[:bookmark])
    unless @bookmark.url.try(:bookmarkable?)
        flash[:notice] = t('bookmark.invalid_url')
      redirect_to user_bookmarks_url(current_user)
      return
    end
    manifestation = @bookmark.get_manifestation
    if manifestation
      if manifestation.bookmarked?(current_user)
        flash[:notice] = t('bookmark.already_bookmarked')
        redirect_to manifestation
        return
      end
      @bookmark.title = manifestation.original_title
    else
      @bookmark.title = Bookmark.get_title_from_url(@bookmark.url) unless @bookmark.title?
    end
  end

  # GET /bookmarks/1;edit
  def edit
    if @user
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
  end

  # POST /bookmarks
  # POST /bookmarks.xml
  def create
    @bookmark = current_user.bookmarks.new(params[:bookmark])
    if @bookmark.url
      unless @bookmark.url.try(:bookmarkable?)
        access_denied; return
      end
    end
    if @bookmark.user != current_user
      access_denied; return
    end
    manifestation = @bookmark.get_manifestation
    if manifestation.try(:bookmarked?, current_user)
      flash[:notice] = t('bookmark.already_bookmarked')
      redirect_to manifestation
      return
    end

    respond_to do |format|
      if @bookmark.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.bookmark'))
        @bookmark.create_tag_index
        @bookmark.manifestation.reload
        @bookmark.manifestation.index!
        if params[:mode] == 'tag_edit'
          format.html { redirect_to(@bookmark.manifestation) }
          format.xml  { render :xml => @bookmark, :status => :created, :location => user_bookmark_url(@bookmark.user, @bookmark) }
        else
          format.html { redirect_to user_bookmark_url(@bookmark.user, @bookmark) }
          format.xml  { render :xml => @bookmark, :status => :created, :location => user_bookmark_url(@bookmark.user, @bookmark) }
        end
      else
        @user = current_user
        format.html { render :action => "new" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end

    session[:params][:bookmark] = nil if session[:params]
  end

  # PUT /bookmarks/1
  # PUT /bookmarks/1.xml
  def update
    if @user
      params[:bookmark][:user_id] = @user.id
      @bookmark = @user.bookmarks.find(params[:id])
    else
      @bookmark = Bookmark.find(params[:id])
    end
    unless @bookmark.url.try(:bookmarkable?)
      access_denied; return
    end
    @bookmark.title = @bookmark.manifestation.try(:original_title)
    @bookmark.taggings.where(:tagger_id => @bookmark.user.id).map{|t| t.destroy}

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.bookmark'))
        @bookmark.manifestation.index!
        @bookmark.create_tag_index
        case params[:mode]
        when 'tag_edit'
          format.html { redirect_to(@bookmark.manifestation) }
          format.xml  { head :ok }
        else
          format.html { redirect_to user_bookmark_url(@bookmark.user, @bookmark) }
          format.xml  { head :ok }
        end
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.xml
  def destroy
    @bookmark.destroy
    flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.bookmark'))
    @bookmark.create_tag_index

    if @user
      respond_to do |format|
        format.html { redirect_to user_bookmarks_url(@user) }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_bookmarks_url(@bookmark.user) }
        format.xml  { head :ok }
      end
    end
  end

  private
  def check_user
    if user_signed_in?
      begin
        if !current_user.has_role?('Librarian')
          raise unless @user.share_bookmarks?
        end
      rescue
        if @user
          unless current_user == @user
            access_denied; return
          end
        else
          redirect_to user_bookmarks_path(current_user)
          return
        end
      end
    end
  end
end
