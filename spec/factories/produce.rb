Factory.define :produce do |f|
  f.manifestation{Factory(:manifestation)}
  f.patron{Factory(:patron)}
end
