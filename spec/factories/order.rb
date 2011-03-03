Factory.define :order do |f|
  f.order_list{Factory(:order_list)}
  f.purchase_request{Factory(:purchase_request)}
end
