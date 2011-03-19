Factory.define :create do |f|
  f.work{Factory(:manifestation)}
  f.patron{Factory(:patron)}
end
