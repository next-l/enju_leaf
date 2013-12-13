class BarcodeRegistrationsController < ApplicationController
  respond_to :html, :json
  #load_and_authorize_resource

  def index
    first_number = params[:first_number]
    last_number = params[:last_number]
 
    #文字が入力されているかどうか
    unless (first_number.blank? || last_number.blank?)
      # 数字、9桁以内、開始番号が終了番号より小さいかの判定
      unless (first_number =~ /\D/ || last_number =~ /\D/  || (first_number.length > 9) || (last_number.length > 9) || (first_number.to_i > last_number.to_i))
        first = first_number.to_i
        last = last_number.to_i
      
        data = String.new
        data << "\xEF\xBB\xBF".force_encoding("UTF-8")# + "\n"
        row = []
        first.upto(last) do |num|
          row << "%09d" % num
        end
        data << '"'+row.join("\",\n\"")+"\"\n"
        send_data data, :filename => Setting.barcode_output.filename + ".csv"
        return
      else
        @error = true
        @first = params[:first_number]
        @last = params[:last_number]
        render :action => "index"
      end
    else
      #片方が入力されている場合の条件分岐
      unless first_number.blank?
        @error = true
        @first = params[:first_number]
      end
      unless last_number.blank?
        @error = true
        @last = params[:last_number]
      end
      render :action => "index"
    end
  end
end

