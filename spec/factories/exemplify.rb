Factory.define :exemplify do |f|
  f.manifestation {Factory(:manifestation)}
  f.item {Factory(:item)}
end
