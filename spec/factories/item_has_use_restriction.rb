Factory.define :item_has_use_restriction do |f|
  f.item{Factory(:item)}
  f.use_restriction{Factory(:use_restriction)}
end
