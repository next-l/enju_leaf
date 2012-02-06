require 'crypt/rijndael'
class BatchactionController < ApplicationController
  Rinjndael_Default_Key = "1234567890123456"

  STAT_SUCCESS = 0
  STAT_ERROR_INVALID_PARAM = 1
  STAT_ERROR_DECODEKEY_EMPTY = 2
  STAT_ERROR_CRYPT = 3

  STAT_ERROR_INVALID_FORMAT = 10
  STAT_ERROR_INVALID_ACTION = 11

  STAT_ERROR_INVALID_CHECKIN_ROWSIZE = 100
  STAT_ERROR_INVALID_CHECKIN_ITEM = 102
  STAT_ERROR_INVALID_CHECKIN_FORMAT = 103

  STAT_ERROR_INVALID_CHECKOUT_ROWSIZE = 200
  STAT_ERROR_INVALID_CHECKOUT_USER = 201
  STAT_ERROR_INVALID_CHECKOUT_ITEM = 202
  STAT_ERROR_INVALID_CHECKOUT_FORMAT = 203
  STAT_ERROR_CHECKOUT = 299

  def initialize
    @actions = []
  end

  def recept
    @statuscode = 0
    @msg = ""

    @statuscode, @msg = decode_action(params[:encodetext])

    render :template => 'batchaction/recept', :layout => false
  end

private

  def default_librarian
    librarian_user = User.librarians.order("users.id").where(:library_id=>library_id).first rescue nil
    if librarian_user.nil?
      logger.warn "librarian not found. library_id=#{library_id} "
      librarian_user = User.find(1) # admin
    end
    librarian_user
  end

  def checkout(row)
    logger.info "checkout start."
    #puts row
    
    messages = []

    unless row.size == 6 
      logger.info "row size is invalid. size=#{row.size}"
      return STAT_ERROR_INVALID_CHECKOUT_ROWSIZE, "checkout row size is invalid. size=#{row.size}"
    end

    user_number = row[3]
    user = User.find_by_user_number(user_number)
    if user.blank? 
      return STAT_ERROR_INVALID_CHECKOUT_USER, "user_number is invalid. (no record) user_number=#{user_number}"
    end 

    item_identifier = row[4]
    item = Item.find_by_item_identifier(item_identifier)
    if item.blank?
      return STAT_ERROR_INVALID_CHECKOUT_ITEM, "item_identifier is invalid. (no record) item_identifier=#{item_identifier}"
    end

    library_id = item.shelf.library.id
    librarian_user = default_librarian(library_id)

    logger.info "librarian.id=#{library_id} librarian_user.id=#{librarian_user.id}"

    worked_at_str = row[5]
    if worked_at_str.blank?
      return STAT_ERROR_INVALID_CHECKOUT_FORMAT, "datetime is blank."
    end
    worked_at = nil
    begin
      worked_at = DateTime.strptime(worked_at_str, "%Y/%m/%d %H:%M:%S")
    rescue ArgumentError
      return STAT_ERROR_INVALID_CHECKOUT_FORMAT, "datetime invalid format. worked_at_str=#{worked_at_str}"
    end

    basket = Basket.new(:user => librarian_user)
    basket.save!(:validate => false)

    checked_item = CheckedItem.new({"item_identifier"=>item_identifier, "ignore_restriction"=>"1"})
    checked_item.basket = basket
    checked_item.item = item 
    checked_item.save
    unless checked_item.errors.empty?
      checked_item.errors[:base].each do |error|
        messages << I18n.t(error)
      end
      logger.info "checked item create error. messages=#{messages}"
      return STAT_ERROR_CHECKOUT, "checked item create error. messages=#{messages.join(" ")}"
    end

    logger.info "save start"
    status = basket.basket_checkout(librarian_user)
    unless status
      basket.errors[:base].each do |error|
        message, sound = error_message_and_sound(error)
        messages << message
      end
      logger.info "basket_checkout error. @@@"
      logger.info messages
      return STAT_ERROR_CHECKOUT, "basket save error. messages=#{messages.join(" ")}"
    end
    logger.info "checkout success."

    return STAT_SUCCESS
  end

  def checkin(row)
    logger.info "checkin start."
    #puts row

    messages = []

    unless row.size == 5
      logger.info "row size is invalid. size=#{row.size}"
      return STAT_ERROR_INVALID_CHECKIN_ROWSIZE, "checkin row size is invalid. size=#{row.size}"
    end

    item_identifier = row[3]
    item = Item.find_by_item_identifier(item_identifier)
    if item.blank?
      return STAT_ERROR_INVALID_CHECKIN_ITEM, "item_identifier is invalid. (no record) item_id=#{item_identifier}"
    end
    unless item.rent? 
      return STAT_ERROR_INVALID_CHECKIN_ITEM, "item_identifier is invalid. (no rent) item_id=#{item_identifier}"
    end
    
    librarian_user = User.librarians.order("users.id").where(:library_id=>library_id).first

    worked_at_str = row[4]
    if worked_at_str.blank?
      return STAT_ERROR_INVALID_CHECKIN_FORMAT, "datetime is blank."
    end
    worked_at = nil
    begin
      worked_at = DateTime.strptime(worked_at_str, "%Y/%m/%d %H:%M:%S")
    rescue ArgumentError
      return STAT_ERROR_INVALID_CHECKIN_FORMAT, "datetime invalid format. worked_at_str=#{worked_at_str}"
    end

    if item.rent?
      unless item.blank?
        basket = Basket.new(:user => librarian_user)
        basket.save!(:validate => false)
        checkin = basket.checkins.new(:item_id => item.id, :librarian_id => librarian_user.id)
        checkin.item = item
        user_id = item.checkouts.select {|checkout| checkout.checkin_id.nil?}.first.user_id rescue nil
        if checkin.save(:validate => false)
          item_messages = checkin.item_checkin(librarian_user, true)
          unless item_messages.blank?
            item_messages.each do |message|
              messages << message if message
            end
          end
        end
      end
    end

    logger.info "checkin success."

    return STAT_SUCCESS, messages.join(" ")
  end

  def actionkeylist
    @actions.collect {|act| act[:name]}
  end

  def decode_action(posttext)
    rinjndael_key = Rinjndael_Default_Key
    plaintext = posttext.chomp rescue ""

    if posttext.nil?
      return STAT_ERROR_INVALID_PARAM, "encodetext is empty."
    end

    if configatron.clientkey.nil?
      return STAT_ERROR_DECODEKEY_EMPTY, "decodekey is empty. see configatron file on server."
    end

=begin
    begin
      rinjndael_key = configatron.clientkey
      puts "key=#{rinjndael_key}"
      rijndael = Crypt::Rijndael.new(rinjndael_key)
      plaintext = rijndael.decrypt_string(encodetext)
    rescue => ex
      logger.info "error occured. BatchactionController#recept.crypt"
      logger.info ex
      logger.info $@.split.join("\n")
      return STAT_ERROR_CRYPT, "crypt error. #{ex} (see serverlog)"
    end
=end

    #puts plaintext
    row = plaintext.split(",")
    require "pp"
    pp row
    #puts row.size
    return [STAT_ERROR_INVALID_FORMAT, "row size is invalid"] if row.size < 4

    @actions = [{:name=>"checkout", :method=>:checkout},
                {:name=>"checkin",  :method=>:checkin}
               ]

    case row[0]
    when *actionkeylist
    else
      return STAT_ERROR_INVALID_ACTION, "invalid action is #{row[0]}"
    end

    #puts row[0]
    return self.send(@actions.select {|act| (act[:name] == row[0])}.first[:method], row)

    #return STAT_SUCCESS
  end
end

