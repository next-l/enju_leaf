Factory.define :reserve_stat_has_manifestation do |f|
  f.manifestation_reserve_stat{Factory(:manifestation_reserve_stat)}
  f.manifestation{Factory(:manifestation)}
end
