Factory.define :participate do |f|
  f.event{Factory(:event)}
  f.patron{Factory(:patron)}
end
