module ItemsHelper
  def call_numberformat(call_number = nil)
    if SystemConfiguration.get("items.call_number.delete_first_delimiter")
      delimiter = current_user.library.call_number_delimiter 
      if call_number.slice(0, 1) == delimiter
        call_number.slice!(0, 1)
      end
    end   
    return call_number
  end
end
