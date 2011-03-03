Factory.define :subscribe do |f|
  f.subscription{Factory(:subscription)}
  f.work{Factory(:manifestation)}
  f.start_at 1.year.ago
  f.end_at 1.year.from_now
end
