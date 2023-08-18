require "rails_helper"

describe LocSearch do
  fixtures :all

  context ".import_from_sru_response" do
    it "should create a valid manifestation", vcr: true do
      manifestation = LocSearch.import_from_sru_response("2007012024")
      expect(manifestation.manifestation_identifier).to eq "14780655"
      expect(manifestation.original_title).to eq "Everything is miscellaneous : the power of the new digital disorder"
      expect(manifestation.manifestation_content_type.name).to eq "text"
      expect(manifestation.carrier_type.name).to eq "volume"
      expect(manifestation.publishers.count).to eq 1
      expect(manifestation.publishers.first.full_name).to eq "Times Books"
      expect(manifestation.publication_place).to eq "New York"
      expect(manifestation.creators.size).to eq 1
      expect(manifestation.creators.first.agent_type.name).to eq "person"
      expect(manifestation.creators.first.full_name).to eq "Weinberger, David, 1950-"
      expect(manifestation.edition_string).to eq "1st ed."
      expect(manifestation.language.iso_639_2).to eq "eng"
      expect(manifestation.date_of_publication.year).to eq 2007
      expect(manifestation.start_page).to eq 1
      expect(manifestation.end_page).to eq 277
      expect(manifestation.height).to eq 25
      expect(manifestation.note).to eq "Includes bibliographical references (p. [235]-257) and index."
      expect(manifestation.description).to eq "Philosopher Weinberger shows how the digital revolution is radically changing the way we make sense of our lives. Human beings constantly collect, label, and organize data--but today, the shift from the physical to the digital is mixing, burning, and ripping our lives apart. In the past, everything had its one place--the physical world demanded it--but now everything has its places: multiple categories, multiple shelves. Everything is suddenly miscellaneous. Weinberger charts the new principles of digital order that are remaking business, education, politics, science, and culture. He examines how Rand McNally decides what information not to include in a physical map (and why Google Earth is winning that battle), how Staples stores emulate online shopping to increase sales, why your children's teachers will stop having them memorize facts, and how the shift to digital music stands as the model for the future.--From publisher description.\nFrom A to Z, Everything Is Miscellaneous will completely reshape the way you think - and what you know - about the world. Includes information on alphabetical order, Amaxon.com, animals, Aristotle, authority, Bettmann Archive, blogs (weblogs), books, broadcasting, British Broadcasting Corporation (BBC), business, card catalog, categories and categorization, clusters, companies, Colon Classification, conversation, Melvil Dewey, Dewey Decimal Classification system, Encyclopaedia Britannica, encyclopedia, essentialism, experts, faceted classification system, first order of order, Flickr.com, Google, Great Books of the Western World, ancient Greeks, health and medical information, identifiers, index, inventory tracking, knowledge, labels, leaf and leaves, libraries, Library of Congress, links, Carolus Linnaeus, lumping and splitting, maps and mapping, marketing, meaning, metadata, multiple listing services (MLS), names of people, neutrality or neutral point of view, New York Public Library, Online Computer Library Center (OCLC), order and organization, people, physical space, everything having place, Plato, race, S.R. Ranganathan, Eleanor Rosch, Joshua Schacter, science, second order of order, simplicity, social constructivism, social knowledge, social networks, sorting,  species, standardization, tags, taxonomies, third order of roder, topical categorization, tree, Uniform Product Code (UPC), users, Jimmy Wales, web, Wikipedia, etc."
      expect(manifestation.statement_of_responsibility).to eq "David Weinberger."
      expect(manifestation.subjects.size).to eq 6
      expect(manifestation.subjects.first.subject_heading_type.name).to eq "lcsh"
      expect(manifestation.subjects.first.subject_type.name).to eq "concept"
      RSpec.describe manifestation.subjects.collect(&:term) do
        it { is_expected.to include("Knowledge management") }
        it { is_expected.to include("Information technology--Management") }
        it { is_expected.to include("Information technology--Social aspects") }
        it { is_expected.to include("Personal information management") }
        it { is_expected.to include("Information resources management") }
        it { is_expected.to include("Order") }
      end
      expect(manifestation.classifications.size).to eq 1
      classification = manifestation.classifications.first
      expect(classification.classification_type.name).to eq "ddc"
      expect(classification.category).to eq "303.48"
      expect(manifestation.identifier_contents("isbn").first).to eq "9780805080438"
      expect(manifestation.identifier_contents("lccn").first).to eq "2007012024"
    end

    it "should parse title information properly", vcr: true do
      manifestation = LocSearch.import_from_sru_response("2012532441")
      expect(manifestation.original_title).to eq "The data journalism handbook"
      expect(manifestation.title_alternative).to eq "How journalists can use data to improve the news"
    end

    it "should distinguish title information with subject", vcr: true do
      m = LocSearch.import_from_sru_response("2008273186")
      expect(m.original_title).to eq "Flexible Rails : Flex 3 on Rails 2"
    end

    it "should create multiple series_statements", vcr: true do
      m = LocSearch.import_from_sru_response("2012471967")
      expect(m.series_statements.size).to eq 2
      RSpec.describe m.series_statements.collect(&:original_title) do
        it { is_expected.to include("The Pragmatic Programmers") }
        it { is_expected.to include("The Facets of Ruby Series") }
      end
    end

    it "should create lcsh subjects only", vcr: true do
      m = LocSearch.import_from_sru_response("2011281911")
      expect(m.subjects.size).to eq 2
      RSpec.describe m.subjects.collect(&:term) do
        it { is_expected.to include("Computer software--Development") }
        it { is_expected.to include("Ruby (Computer program language)") }
      end
    end

    it "should support name and title subjects", vcr: true do
      m = LocSearch.import_from_sru_response("2013433146")
      expect(m.subjects.size).to eq 3
      RSpec.describe m.subjects.collect(&:term) do
        it { is_expected.to include("Montgomery, L. M. (Lucy Maud), 1874-1942. Anne of Green Gables") }
        it { is_expected.to include("Montgomery, L. M. (Lucy Maud), 1874-1942--Criticism and interpretation") }
        it { is_expected.to include("Montgomery, L. M. (Lucy Maud), 1874-1942--Influence") }
      end
    end

    it "should import note fields", vcr: true do
      m = LocSearch.import_from_sru_response("2010526151")
      expect(m.note).not_to be_nil
      expect(m.note).not_to be_empty
      expect(m.note).to eq %Q["This is a book about the design of user interfaces for search and discovery"--Pref.;\n"January 2010"--T.p. verso.;\nIncludes bibliographical references and index.]
    end

    it "should import publication year", vcr: true do
      m = LocSearch.import_from_sru_response("2001315134")
      expect(m.date_of_publication.year).to eq 2000
    end

    it "should import e-resource", vcr: true do
      m = LocSearch.import_from_sru_response("2005568297")
      expect(m.carrier_type).to eq CarrierType.where(name: "online_resource").first
      expect(m.access_address).to eq "http://portal.acm.org/dl.cfm"
    end

    it "should import e-resource (packaged)", vcr: true do
      m = LocSearch.import_from_sru_response("2006575029")
      expect(m.original_title).to eq "Microsoft Encarta 2006 premium"
      expect(m.statement_of_responsibility).to eq "Microsoft Corporation"
      expect(m.carrier_type).to eq CarrierType.where(name: "online_resource").first
      expect(m.manifestation_content_type).to eq ContentType.where(name: "other").first
    end

    it "should import audio book", vcr: true do
      m = LocSearch.import_from_sru_response("2007576782") # RDA metadata
      expect(m.manifestation_content_type).to eq ContentType.where(name: "spoken_word").first
      expect(m.carrier_type).to eq CarrierType.where(name: "audio_disc").first
    end

    it "should import video publication", vcr: true do
      m = LocSearch.import_from_sru_response("2013602064")
      expect(m.manifestation_content_type).to eq ContentType.where(name: "two_dimensional_moving_image").first
      expect(m.carrier_type).to eq CarrierType.where(name: "videodisc").first
    end

    it "should import serial", vcr: true do
      m = LocSearch.import_from_sru_response("00200486")
      expect(m.original_title).to eq "Science and technology of advanced materials"
      expect(m.serial).to be_truthy
      expect(m.issn_records.first.body).to eq "14686996"
      expect(m.identifier_contents(:issn_l).first).to eq "14686996"
      expect(m.frequency.name).to eq "bimonthly"
      series_statement = m.series_statements.first
      expect(series_statement.original_title).to eq "Science and technology of advanced materials"
      expect(series_statement.series_master).to be_truthy
    end
    it "should import another serial", vcr: true do
      m = LocSearch.import_from_sru_response("88651712")
      expect(m.original_title).to eq "Superconductor science & technology"
      expect(m.title_alternative).to eq "Supercond. sci. technol ; Superconductor science and technology"
      expect(m.serial).to be_truthy
      expect(m.issn_record.first.body).to eq "09532048"
      expect(m.identifier_contents(:issn_l).first).to eq "09532048"
      expect(m.frequency.name).to eq "monthly"
      series_statement = m.series_statements.first
      expect(series_statement.original_title).to eq m.original_title
      expect(series_statement.title_alternative).to eq m.title_alternative
      expect(series_statement.series_master).to be_truthy
    end

    it "should import a manifestation that has invalid classification", vcr: true do
      m = LocSearch.import_from_sru_response("2014381788")
      expect(m).to be_valid
      expect(m.classifications).to be_empty
    end

    it "should import notated music", vcr: true do
      m = LocSearch.import_from_sru_response("2014563060")
      expect(m.manifestation_content_type).to eq ContentType.where(name: 'notated_music').first
      expect(m.language_id).to eq 1 # language: unknown
    end

    it "should import lccn exact math", vcr: true do
      m = LocSearch.import_from_sru_response("93028401")
      expect(m).to be_valid
      expect(m.original_title).to eq "How to lie with statistics"
    end

    it "should import extent", vcr: true do
      m = LocSearch.import_from_sru_response("94041789")
      expect(m).to be_valid
      expect(m.original_title).to eq "The little boat"
      expect(m.extent).to eq "1 v. (unpaged) : col. ill."
      expect(m.dimensions).to eq "25 x 29 cm."
    end
  end

  context ".search", vcr: true do
    it "should return a search result", vcr: true do
      result = LocSearch.search('library')
      expect(result[:total_entries]).to eq 10000
    end
  end

  context "::ModsRecord" do
    it "should parse MODS metadata", vcr: true do
      results = LocSearch.search("bath.lccn=2007012024")
      metadata = results[ :items ].first
      expect(metadata.lccn).to eq "2007012024"
      expect(metadata.title).to eq "Everything is miscellaneous : the power of the new digital disorder"
      expect(metadata.creator).to eq "David Weinberger."
      expect(metadata.pubyear).to eq "2007"
      expect(metadata.publisher).to eq "Times Books"
      expect(metadata.isbn).to eq "9780805080438"
    end
  end

  context ".make_sru_request_uri" do
    it "should construct a valid uri" do
      url = LocSearch.make_sru_request_uri("test")
      uri = URI.parse(url)
      expect(Hash[uri.query.split(/\&/).collect{|e| e.split(/=/) }]).to eq({
        "query" => "test",
        "version" => "1.1",
        "operation" => "searchRetrieve",
        "maximumRecords" => "10",
        "recordSchema" => "mods"
      })
    end

    it "should support pagination" do
      url = LocSearch.make_sru_request_uri("test", page: 2)
      uri = URI.parse(url)
      expect(Hash[uri.query.split(/\&/).collect{|e| e.split(/=/) }]).to eq({
        "query" => "test",
        "version" => "1.1",
        "operation" => "searchRetrieve",
        "maximumRecords" => "10",
        "recordSchema" => "mods",
        "startRecord" => "11",
      })
    end
  end
end
