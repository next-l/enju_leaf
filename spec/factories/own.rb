Factory.define :own do |f|
  f.item{Factory(:item)}
  f.patron{Factory(:patron)}
end
