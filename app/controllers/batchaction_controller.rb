require 'crypt/rijndael'
class BatchactionController < ApplicationController
  Rinjndael_Default_Key = "1234567890123456"

  STAT_SUCCESS = 0
  STAT_ERROR_INVALID_PARAM = 1
  STAT_ERROR_DECODEKEY_EMPTY = 2
  STAT_ERROR_CRYPT = 3

  def recept
    @statuscode = 0
    @msg = ""

    @statuscode, @msg = decodeaction(params[:encodetext])

    render :template => 'batchaction/recept', :layout => false
  end

private
  def decodeaction(encodetext)
    rinjndael_key = Rinjndael_Default_Key
    plaintext = ""

    if encodetext.nil?
      return STAT_ERROR_INVALID_PARAM, "encodetext is empty."
    end

    if configatron.clientkey.nil?
      return STAT_ERROR_DECODEKEY_EMPTY, "decodekey is empty. see configatron file on server."
    end

    begin
      rinjndael_key = configatron.clientkey
      rijndael = Crypt::Rijndael.new(rinjndael_key)
      plaintext = rijndael.decrypt_string(encodetext)
    rescue => ex
      logger.info "error occured. BatchactionController#recept.crypt"
      logger.info ex
      logger.info $@
      return STAT_ERROR_CRYPT, "crypt error #{ex} (see serverlog)"
    end

    puts plaintext
    row = plaintext.split("\t")

    return STAT_SUCCESS
  end
end

