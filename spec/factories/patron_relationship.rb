Factory.define :patron_relationship do |f|
  f.parent{Factory(:patron)}
  f.child{Factory(:patron)}
end
