Factory.define :manifestation_relationship do |f|
  f.parent{Factory(:manifestation)}
  f.child{Factory(:manifestation)}
end
