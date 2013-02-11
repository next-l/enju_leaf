# -*- encoding: utf-8 -*-
require "rexml/document"

=begin
class Patron < ActiveRecord::Base
  def self.import_patrons(patron_lists)
    patrons = []
    patron_lists.each do |patron_list|
      name_and_role = patron_list[:full_name].split('||')
      if patron_list[:patron_identifier].present?
        patron = Patron.where(:patron_identifier => patron_list[:patron_identifier]).first
      else
        patron = Patron.where(:full_name => name_and_role[0]).first
      end
      role_type = name_and_role[1].to_s.strip
      unless patron
        patron = Patron.new(
          :full_name => name_and_role[0],
          :full_name_transcription => patron_list[:full_name_transcription],
          :patron_identifier => patron_list[:patron_identifier],
          :language_id => 1
        )
        #patron.required_role = Role.where(:name => 'Guest').first
        patron.save
      end
      patrons << patron
    end
    patrons
  end
end
=end

class Xml2DbService
  include REXML 
  MAX_RECORD = 1

  attr_accessor :languages, :carriertypes, :countries

  def self.import_start(filename)
    return self.new.import(filename)
  end

  def import(filename)
    lines = 0
    clearManifestations
    @languages = Language.all
    @carriertypes = CarrierType.all
    @countries = Country.all

    open(filename) {|file|
      while l = file.gets
        break if lines > MAX_RECORD
        lines += 1
        h = Hash.from_xml(l)
        build_manifestation(h)

      end
    }
    #Sunspot.commit

    puts "Total #{lines} lines"
  end

  def get_publishers(publishers_raw)
    publishers = []
    p = publishers_raw
    #publishers_raw.each do |p|
      publishers << {
        :full_name => p['name'],
        :full_name_transcription => p['transcription']
      }
    #end
    return publishers
  end

  def build_manifestation(h)
    bibResource = h['ndl_iss']['bibResource']
    item_raw = h['ndl_iss']['item']
    original_title = bibResource['title']['value']
    transcription = bibResource['title']['transcription']
    volume = bibResource['volume'] rescue nil
    series = bibResource['seriesTitle']
    series_title = series['value']
    series_transcription = series['transcription']
    creators = bibResource['creator']
    responsibilities = bibResource['responsibility']
    publishers_raw = bibResource['publisher']
    publicationPlace = bibResource['publicationPlace']
    publicationDate = bibResource['publicationDate']
    issued = bibResource['issued']
    description = bibResource['description']
    classification = bibResource['classification']
    classification = classification.first
    language = bibResource['language']
    publishers = get_publishers(publishers_raw)
    extent = bibResource['extent']

    puts "@@@"
    puts h
    puts "@@@"
    puts bibResource
    puts "@@@"
    puts item_raw

    m = Manifestation.new
    m.original_title = original_title
    m.title_transcription = transcription
    m.classification_number = classification.tr('０-９．','0-9.')
    m.date_of_publication = publicationDate
    m.place_of_publication = publicationPlace

    m.country_of_publication = @countries.find {|c| c.alpha_2 == publicationPlace}
    m.language = @languages.find {|lang| lang.iso_639_2 == language} rescue @languages.first
    m.note = description
    m.carrier_type_id = 1
    m.required_role = Role.find('Guest')

    publisher_patrons = Patron.import_patrons(publishers)

    unless m.save
      puts "error"
      puts m.errors.full_messages
      puts m
      return
    end
    
    #m.publishers << publisher_patrons
    create_series_statement(h, m)
    create_item(h, m)
  end

  def create_series_statement(h, m)

  end

  def create_item(h, m)
    item_raw = h['ndl_iss']['item']
    item = Item.new
    item.item_identifier = item_raw['issId'].gsub(/[-]/, "")
    item.manifestation = m
    item.save!
  end

  def clearManifestations
    Patron.destroy_all(["user_id is null and exclude_state = 0"])
    Item.destroy_all
    Manifestation.destroy_all
  end
end
