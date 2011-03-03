Factory.define :checkout_stat_has_manifestation do |f|
  f.manifestation_checkout_stat{Factory(:manifestation_checkout_stat)}
  f.manifestation{Factory(:manifestation)}
end
