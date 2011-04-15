Factory.define :reserve do |f|
  f.manifestation{Factory(:manifestation)}
  f.user{Factory(:user)}
end
