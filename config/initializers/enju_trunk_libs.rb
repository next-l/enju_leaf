Dir[Rails.root.to_s + "/lib/enju_trunk/**/*.rb"].each do 
  |file|
  require file
end
