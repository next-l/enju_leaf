Factory.define :subject_has_classification do |f|
  f.classification{Factory(:classification)}
  f.subject{Factory(:subject)}
end
