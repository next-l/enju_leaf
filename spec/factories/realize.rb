Factory.define :realize do |f|
  f.expression{Factory(:manifestation)}
  f.patron{Factory(:patron)}
end
