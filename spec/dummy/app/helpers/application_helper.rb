module ApplicationHelper
  include EnjuLeaf::EnjuLeafHelper
  include EnjuBiblio::BiblioHelper if defined?(EnjuBiblio)
end
