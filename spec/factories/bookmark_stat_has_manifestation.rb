Factory.define :bookmark_stat_has_manifestation do |f|
  f.bookmark_stat{Factory(:bookmark_stat)}
  f.manifestation{Factory(:manifestation)}
end
