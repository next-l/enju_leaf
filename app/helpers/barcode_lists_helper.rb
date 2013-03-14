module BarcodeListsHelper
  def barcode_list_usage_name(type_id) 
    BarcodeList::GENERATED_FROM.find{|t| t.split(":").first == type_id}.split(":").last rescue type_id
  end
end
