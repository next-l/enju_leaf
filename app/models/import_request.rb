class ImportRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :manifestation, :class_name => 'Resource'

  enju_ndl

  def self.import_patrons(patron_lists)
    patrons = []
    patron_lists.each do |patron_list|
      unless patron = Patron.first(:conditions => {:full_name => patron_list})
        patron = Patron.new(:full_name => patron_list) #, :language_id => 1)
        #patron.required_role = Role.first(:conditions => {:name => 'Guest'})
      end
      patron.save
      patrons << patron
    end
    patrons
  end

  def import!
    manifestation = self.class.import_isbn!(isbn)
    self.manifestation = manifestation
    save!
  end

end
