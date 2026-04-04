class AddNotNullToFamilyNameFirstOnLibraryGroups < ActiveRecord::Migration[7.2]
  def change
    change_column_default :library_groups, :family_name_first, false
    change_column_default :manifestations, :fulltext_content, false
    change_column_default :manifestations, :serial, false
    change_column_default :profiles, :share_bookmarks, false
    change_column_default :reserves, :expiration_notice_to_library, false
    change_column_default :reserves, :expiration_notice_to_patron, false
    change_column_default :series_statements, :series_master, false

    LibraryGroup.where(family_name_first: nil).find_each do |i|
      i.update_column(:family_name_first, false)
    end
    Manifestation.where(fulltext_content: nil).find_each do |i|
      i.update_column(:fulltext_content, false)
    end
    Manifestation.where(serial: nil).find_each do |i|
      i.update_column(:serial, false)
    end
    Profile.where(share_bookmarks: nil).find_each do |i|
      i.update_column(:share_bookmarks, false)
    end
    Reserve.where(expiration_notice_to_library: nil).find_each do |i|
      i.update_column(:expiration_notice_to_library, false)
    end
    Reserve.where(expiration_notice_to_patron: nil).find_each do |i|
      i.update_column(:expiration_notice_to_patron, false)
    end
    SeriesStatement.where(series_master: nil).find_each do |i|
      i.update_column(:series_master, false)
    end

    change_column_null :library_groups, :family_name_first, false
    change_column_null :manifestations, :fulltext_content, false
    change_column_null :manifestations, :serial, false
    change_column_null :profiles, :share_bookmarks, false
    change_column_null :reserves, :expiration_notice_to_library, false
    change_column_null :reserves, :expiration_notice_to_patron, false
    change_column_null :series_statements, :series_master, false
  end
end
