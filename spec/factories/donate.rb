Factory.define :donate do |f|
  f.item{Factory(:item)}
  f.patron{Factory(:patron)}
end
