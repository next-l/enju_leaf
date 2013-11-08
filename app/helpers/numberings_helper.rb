module NumberingsHelper
  def get_numbering_display_name(numbering_name, manifestation_type_id = 0)
    numbering = Numbering.where(:name => numbering_name).first.try(:display_name) rescue nil
    unless numbering
      manifestation_type = ManifestationType.find(manifestation_type_id) rescue nil
      if manifestation_type
        if manifestation_type.is_article?
          numbering =  Numbering.where(:name => 'article').first.try(:display_name)
        else
          numbering = Numbering.where(:name => 'book').first.try(:display_name)
        end  
      end
    end
    return numbering
  end
end
