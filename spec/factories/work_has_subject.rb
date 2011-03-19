Factory.define :work_has_subject do |f|
  f.work{Factory(:manifestation)}
  f.subject{Factory(:subject)}
end
