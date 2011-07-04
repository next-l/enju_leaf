xml.instruct! :xml, :version=>"1.0"
xml.mods('version' => "3.3",
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns' => "http://www.loc.gov/mods/v3"){
  xml << render('manifestations/show', :manifestation => @manifestation)
}
