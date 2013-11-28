# encoding: utf-8
class ExchangeManifestationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_librarian

  def new
  end

  def select_manifestation
    @errors = []
    exchange_manifestation = params[:exchange_manifestation]
    if exchange_manifestation.present? && exchange_manifestation["item_identifier"].present?
      @item_identifier = exchange_manifestation["item_identifier"]
      @item = Item.where(["item_identifier = ?", @item_identifier]).first
      unless @item
        @errors << I18n.t('exchange_manifestation.item_not_found')
      else
        unless @item.exchangeable?
          if exchange_manifestation["force_exchange"].blank?
            @errors << I18n.t('exchange_manifestation.item_circulation_status_is_invalid')
          end
        end
      end
    else
      @errors << I18n.t('exchange_manifestation.no_item_identifier')
    end
    
    if @errors.size > 0
      render :new
    end

  end

  def update
    @errors = []
    @dest_manifestation = Manifestation.find(params[:dest_manifestation_id])
    @titem = Item.where(["item_identifier = ?", params[:item_identifier]]).first
    begin
      ActiveRecord::Base.transaction do 
        if SystemConfiguration.get('manifestation.manage_item_rank') 
          @titem.rank = Item::RANK_SPARE
          @titem.save!
        end 
        @titem.manifestation = @dest_manifestation       
        unless @titem.manifestation.save
          e = Exemplify.where(:item_id => @titem.id).first
          e.manifestation_id = @dest_manifestation.id
          e.save!(:validate => false)
          @titem.index
        end
      end
    rescue => e
      logger.fatal "error. item_exchange unsuccess."
      logger.fatal e.message
      logger.fatal e.backtrace.join("\n")
      render :select_manifestation
    end

    flash.now[:notice] = I18n.t('exchange_manifestation.exchange_success')
    render :new
  end
end
