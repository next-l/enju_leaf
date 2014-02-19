class Setting < Settingslogic
  source "#{Rails.root}/config/enju_leaf.yml"
  namespace Rails.env
end
