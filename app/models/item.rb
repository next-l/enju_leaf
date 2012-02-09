# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  scope :for_checkout, where('item_identifier IS NOT NULL')
  scope :not_for_checkout, where(:item_identifier => nil)
  scope :on_shelf, where('shelf_id != 1')
  scope :on_web, where(:shelf_id => 1)
  scope :recent, where(['items.created_at >= ?', Time.zone.now.months_ago(1)])
  scope :for_retain_from_own, lambda{|library| where('shelf_id IN (?)', library.shelf_ids).order('created_at ASC')}
  scope :for_retain_from_others, lambda{|library| where('shelf_id NOT IN (?)', library.shelf_ids).order('created_at ASC')}
  has_one :exemplify
  has_one :manifestation, :through => :exemplify
  has_many :checkouts
  has_many :reserves
  has_many :reserved_patrons, :through => :reserves, :class_name => 'Patron'
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  delegate :display_name, :to => :shelf, :prefix => true
  has_many :checked_items, :dependent => :destroy
  has_many :baskets, :through => :checked_items
  belongs_to :circulation_status, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  has_one :item_has_use_restriction, :dependent => :destroy
  has_one :use_restriction, :through => :item_has_use_restriction
  has_many :reserves
  has_many :inter_library_loans, :dependent => :destroy
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  belongs_to :checkout_type
  has_many :inventories, :dependent => :destroy
  has_many :inventory_files, :through => :inventories
  has_many :lending_policies, :dependent => :destroy
  has_many :answer_has_items, :dependent => :destroy
  has_many :answers, :through => :answer_has_items
  has_one :resource_import_result
  has_many :libcheck_tmp_items
  has_many :expenses

  validates_associated :circulation_status, :shelf, :bookstore, :checkout_type
  validates_presence_of :circulation_status, :checkout_type
  validates :item_identifier, :allow_blank => true, :uniqueness => {:if => proc{|item| !item.item_identifier.blank? and !item.manifestation.try(:series_statement)}}, :format => {:with => /\A[0-9A-Za-z_]+\Z/}
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validates_date :acquired_at, :allow_blank => true
  before_validation :set_circulation_status, :on => :create
  before_save :set_use_restriction, :check_remove_item, :check_price

  #enju_union_catalog
  has_paper_trail
  normalize_attributes :item_identifier

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher, :library
    string :item_identifier
    string :library
    integer :required_role_id
    integer :circulation_status_id
    integer :manifestation_id do
      manifestation.id if manifestation
    end
    integer :shelf_id
    integer :patron_ids, :multiple => true
    integer :inventory_file_ids, :multiple => true
    time :created_at
    time :updated_at
  end

  attr_accessor :library_id, :manifestation_id, :use_restriction_id

  def self.per_page
    10
  end

  def set_circulation_status
    self.circulation_status = CirculationStatus.where(:name => 'In Process').first if self.circulation_status.nil?
  end

  def set_use_restriction
    if self.use_restriction_id
      self.use_restriction = UseRestriction.where(:id => self.use_restriction_id).first
    else
      self.use_restriction = UseRestriction.where(:name => 'Limited Circulation, Normal Loan Period').first
    end
  end

  def checkout_status(user)
    user.user_group.user_group_has_checkout_types.find_by_checkout_type_id(self.checkout_type.id)
  end

  def next_reservation
    Reserve.waiting.where(:manifestation_id => self.manifestation.id).first
  end

  def reserved?
    return true unless Reserve.waiting.where(:item_id => self.id).blank?
    false
#    return true if self.next_reservation
#    false
  end

  def reserve
    Reserve.waiting.where(:item_id => self.id).first 
  end

  def reservable?
    return false if ['Lost', 'Missing', 'Claimed Returned Or Never Borrowed'].include?(self.circulation_status.name)
    return false if self.item_identifier.blank?
    true
  end

  def available_checkin?
    return false if ['Circulation Status Undefined', 'Missing'].include?(self.circulation_status.name)
    true
  end

  def rent?
    return true if self.checkouts.not_returned.select(:item_id).detect{|checkout| checkout.item_id == self.id}
    false
  end

  def reserved_by_user?(user)
    if self.reserve
      return true if self.reserve.user == user
    end
    false
  end

  def checkout_reserved_item(user)
    reservation = Reserve.waiting.where(:user_id => user.id, :manifestation_id => self.manifestation.id).first rescue nil
    if reservation
      logger.error "checkouts reservation: #{reservation.id}"
      reservation.item = self
      reservation.sm_complete!
      reservation.update_attributes(:checked_out_at => Time.zone.now)     
      return reservation
    end
  end

  def available_for_checkout?
    circulation_statuses = CirculationStatus.available_for_checkout.select(:id)
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def available_for_retain?
    circulation_statuses = CirculationStatus.available_for_retain.select(:id)
    return true if circulation_statuses.include?(self.circulation_status)
    false
  end

  def available_for_reserve_with_config?
    c = CirculationStatus.where(:name => 'On Loan').first
    return true if c.id == self.circulation_status.id
    false
  end

  def checkout!(user, librarian = nil)
    circulation_status_on_loan = CirculationStatus.where(:name => 'On Loan').first
    if self.circulation_status == circulation_status_on_loan
      @basket = Basket.new(:user => librarian)
      @basket.save(:validate => false)
      @checkin = @basket.checkins.new(:item_id => self.id, :librarian_id => librarian.id)
      @checkin.save(:validate => false)
      @checkin.item_checkin(user, true)
    end
    self.circulation_status = circulation_status_on_loan
    reservation = checkout_reserved_item(user)
#    if self.reserved_by_user?(user)
#      reservation = self.reserve
#      reservation.sm_complete!
#      reservation.update_attributes(:checked_out_at => Time.zone.now)
#    end
    save!
    reservation.position_update(reservation.manifestation) if reservation
  end

  def checkin!
    self.circulation_status = CirculationStatus.where(:name => 'Available On Shelf').first
    save(:validate => false)
  end

  def retain(librarian)
    Item.transaction do
      reservation = self.manifestation.next_reservation
      unless reservation.nil?
        reservation.item = self
        reservation.sm_retain!
        reservation.update_attributes({:request_status_type => RequestStatusType.find_by_name('In Process')})
        request = MessageRequest.new(:sender_id => librarian.id, :receiver_id => reservation.user_id)
        message_template = MessageTemplate.localized_template('item_received', reservation.user.locale)
        request.message_template = message_template
        request.save!
      end
    end
  end

  def retain_item!
    self.circulation_status = CirculationStatus.find(:first, :conditions => ["name = ?", 'Available For Pickup'])
    self.save
  end

  def cancel_retain!
    self.circulation_status = CirculationStatus.find(:first, :conditions => ["name = ?", 'Available On Shelf'])
    self.save
  end

  def inter_library_loaned?
    true if self.inter_library_loans.size > 0
  end

  def title
    manifestation.try(:original_title)
  end

  def creator
    manifestation.try(:creator)
  end

  def contributor
    manifestation.try(:contributor)
  end

  def publisher
    manifestation.try(:publisher)
  end

  def library
    shelf.library.name if shelf
  end

  def shelf_name
    shelf.name
  end

  def hold?(library)
    return true if self.shelf.library == library
    false
  end

  def self.inventory_items(inventory_file, mode = 'not_on_shelf')
    item_ids = Item.select(:id).collect(&:id)
    inventory_item_ids = inventory_file.items.select('items.id').collect(&:id)
    case mode
    when 'not_on_shelf'
      Item.where(:id => (item_ids - inventory_item_ids))
    when 'not_in_catalog'
      Item.where(:id => (inventory_item_ids - item_ids))
    end
  rescue
    nil
  end

  def lending_rule(user)
    lending_policies.where(:user_group_id => user.user_group.id).first
  end

  def owned(patron)
    owns.where(:patron_id => patron.id).first
  end

  def library_url
    "#{LibraryGroup.site_config.url}libraries/#{self.shelf.library.name}"
  end

  def manifestation_url
    Addressable::URI.parse("#{LibraryGroup.site_config.url}manifestations/#{self.manifestation.id}").normalize.to_s if self.manifestation
  end

  def deletable?
    checkouts.not_returned.empty? && (self.manifestation.items.size > 1 || self.circulation_status.name == "Removed" || SystemConfiguration.get("items.confirm_destroy") == false)
  end

  def not_for_loan?
    if use_restriction.try(:name) == 'Not For Loan'
      true
    else
      false
    end
  end

  def check_remove_item
    if self.circulation_status_id == CirculationStatus.find(:first, :conditions => ["name = ?", 'Removed']).id
      self.removed_at = Time.zone.now if self.removed_at.nil?
    else
      self.removed_at = nil
    end
  end

  def check_price
    record = Expense.where(:item_id => self.id).order("id DESC").first
    begin
      unless record.nil?
        return if self.price == record.price
        Expense.transaction do
          Expense.create!(:item_id => self.id, :budget_id => record.budget_id, :price => record.price*-1)
          budget = Budget.joins(:term).where(:library_id => self.shelf.library.id).order("terms.start_at DESC").first
          Expense.create!(:item_id => self.id, :budget_id => budget.id, :price => self.price) if budget
        end
      else
        budget = Budget.joins(:term).where(:library_id => self.shelf.library.id).order("terms.start_at DESC").first
        Expense.create!(:item_id => self.id, :budget_id => budget.id, :price => self.price) if budget
      end
    rescue Exception => e
      logger.error "Failed to update expense: #{e}"
    end
  end

  def self.export_removing_list(out_dir, file_type = nil)
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    tsv_file = out_dir + "removing_list.tsv"
    pdf_file = out_dir + "removing_list.pdf"
    logger.info "output removing_list tsv: #{tsv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    
    items = Item.where('removed_at IS NOT NULL').order('removed_at ASC, id ASC')
    if items
      # tsv
      if file_type.nil? || file_type == "tsv"
        columns = [
          ['item_identifier','activerecord.attributes.item.item_identifier'],
          ['removed_at', 'activerecord.attributes.item.removed_at'],
          ['acquired_at', 'activerecord.attributes.item.acquired_at'],
          [:original_title,'activerecord.attributes.manifestation.original_title'],
          [:date_of_publication, 'activerecord.attributes.manifestation.date_of_publication'],
          [:patron_creator, 'patron.creator'],
          [:patron_publisher,'patron.publisher'], 
          ['price', 'activerecord.attributes.item.price'],
          ['note', 'activerecord.attributes.item.note']
        ]
        File.open(tsv_file, "w") do |output|
          # add UTF-8 BOM for excel
          output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

          # タイトル行
          row = []
          columns.each do |column|
            row << I18n.t(column[1])
          end
          output.print '"'+row.join("\"\t\"")+"\n"
  
          items.each do |item|
            row = []
            columns.each do |column|
              case column[0]
              when :original_title
                row << item.manifestation.original_title
              when :date_of_publication
                if item.manifestation.date_of_publication.nil?
                  row << ""
                else
                  row << item.manifestation.date_of_publication.strftime("%Y-%m-%d")
                end
              when :patron_creator
                row << patrons_list(item.manifestation.creators)
              when :patron_publisher
                row << patrons_list(item.manifestation.publishers)
              else
                row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
              end # end of case column[0]
            end #end of columns.each
            output.print '"'+row.join("\"\t\"")+"\"\n"
          end # end of items.each
        end
      end
      # pdf
      if file_type.nil? || file_type == "pdf"
        report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'removing_list.tlf') 
        report.events.on :page_create do |e|
          e.page.item(:page).value(e.page.no)
        end
        report.events.on :generate do |e|
          e.pages.each do |page|
            page.item(:total).value(e.report.page_count)
          end
        end

        report.start_new_page do |page|
          page.item(:date).value(Time.now)
          items.each do |item|
            page.list(:list).add_row do |row|
              row.item(:item_identifier).value(item.item_identifier)
              unless item.acquired_at.nil?
                row.item(:acquired_at).value(item.acquired_at.strftime("%Y/%m/%d"))
              end
              unless item.removed_at.nil?
                row.item(:removed_at).value(item.removed_at.strftime("%Y/%m/%d"))
              end
              row.item(:title).value(item.manifestation.original_title)
              unless item.manifestation.date_of_publication.nil?
                #row.item(:date_of_publication).value(item.manifestation.date_of_publication.strftime("%Y/%m/%d"))
              end
              row.item(:price).value(to_format(item.price))
              row.item(:patron_creator).value(patrons_list(item.manifestation.creators))
              row.item(:patron_publisher).value(patrons_list(item.manifestation.publishers))
             end
          end
        end
        report.generate_file(pdf_file)
      end
    end  #end of method
  end

  def self.export_item_register(out_dir, file_type = nil) 
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    tsv_file = out_dir + "item_register.tsv"
    pdf_file = out_dir + "item_register.pdf"
    logger.info "output item_register tsv: #{tsv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # get item
    @items = Item.order("bookstore_id DESC, acquired_at ASC, item_identifier ASC").all
    # make tsv
    make_item_register_tsv(tsv_file, @items) if file_type.nil? || file_type == "tsv"
    # make pdf
    make_item_register_pdf(pdf_file, @items) if file_type.nil? || file_type == "pdf"
  end

  def self.export_audio_list(out_dir, file_type = nil)
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    tsv_file = out_dir + "audio_list.tsv"
    pdf_file = out_dir + "audio_list.pdf"
    logger.info "output audio_list tsv: #{tsv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # get item
    carrier_type_ids = CarrierType.audio.inject([]){|ids, c| ids << c.id}
    @items = Item.joins(:manifestation).where(["manifestations.carrier_type_id IN (?)", carrier_type_ids]).order("bookstore_id DESC, acquired_at ASC, item_identifier ASC").all
    # make tsv
    make_audio_list_tsv(tsv_file, @items) if file_type.nil? || file_type == "tsv"
    # make pdf
    make_audio_list_pdf(pdf_file, @items) if file_type.nil? || file_type == "pdf"
  end

  private
  def self.to_format(num)
    num.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end

  def self.patrons_list(patrons)
    ApplicationController.helpers.patrons_list(patrons, {:nolink => true})
  end

  def self.get_object_method(obj,array)
    _obj = obj.send(array.shift)
    return get_object_method(_obj, array) if array.present?
    return _obj
  end

  def self.make_item_register_tsv(tsvfile, items)
    columns = [
      [:bookstore, 'activerecord.models.bookstore'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      ['acquired_at', 'activerecord.attributes.item.acquired_at'],
      [:creator, 'patron.creator'],
      [:original_title, 'activerecord.attributes.manifestation.original_title'],
      [:pub_year, 'activerecord.attributes.manifestation.pub_year'],
      [:publisher, 'patron.publisher'],
      [:price, 'activerecord.attributes.manifestation.price'],
      ['call_number', 'activerecord.attributes.item.call_number'],
      [:marc_number, 'activerecord.attributes.manifestation.marc_number'],
      ['note', 'activerecord.attributes.item.note']
    ]
  
    File.open(tsvfile, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print '"'+row.join("\"\t\"")+"\"\n"
      if items.nil? || items.size < 1
        logger.warn "item data is empty"
      else
        items.each do |item|
          row = []
          columns.each do |column|
            case column[0]
            when :bookstore
              if item.bookstore
                row << item.bookstore.name
              else
                row << ""
              end
            when :creator
              if item.manifestation && item.manifestation.creators
                row << item.manifestation.creators.inject([]){|names, creator| names << creator.full_name if creator.full_name; names}.join("\t")
              else
                row << ""
              end
            when :original_title
              if item.manifestation
                row << item.manifestation.original_title
              else
                row << ""
              end
            when :pub_year
              if item.manifestation && item.manifestation.date_of_publication
                row << item.manifestation.date_of_publication.strftime("%Y")
              else 
                row << ""
              end
            when :publisher
              if item.publisher
                row << item.publisher.delete_if{|p|p.blank?}.join("\t")
              else
                row << ""
              end
            when :price
              if item.manifestation && item.manifestation.price
                row << item.manifestation.price
              else
                row << ""
              end
            when :marc_number
              if item.manifestation && item.manifestation.marc_number
                row << item.manifestation.marc_number[0, 10]
              else
                row << ""
              end
            else
              row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
            end
          end
          output.print '"'+row.join("\"\t\"")+"\"\n"
        end  
      end
    end
  end

  def self.make_audio_list_tsv(tsvfile, items)
    columns = [
      [:library, 'activerecord.models.library'],
      [:carrier_type, 'activerecord.models.carrier_type'],
      [:shelf, 'activerecord.models.shelf'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      ['acquired_at', 'activerecord.attributes.item.acquired_at'],
      [:original_title, 'activerecord.attributes.manifestation.original_title'],
      [:creator, 'patron.creator'],
      [:pub_year, 'activerecord.attributes.manifestation.pub_year'],
      [:publisher, 'patron.publisher'],
      ['call_number', 'activerecord.attributes.item.call_number'],
      ['note', 'activerecord.attributes.item.note']
    ]
  
    File.open(tsvfile, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print '"'+row.join("\"\t\"")+"\"\n"
      if items.nil? || items.size < 1
        logger.warn "item data is empty"
      else
        items.each do |item|
          row = []
          columns.each do |column|
            case column[0]
            when :library
              if item.shelf && item.shelf.library
                row << item.shelf.library.display_name.localize
              else
                row << ""
              end
            when :creator
              if item.manifestation && item.manifestation.creators
                row << item.manifestation.creators.inject([]){|names, creator| names << creator.full_name if creator.full_name; names}.join("\t")
              else
                row << ""
              end
            when :original_title
              if item.manifestation
                row << item.manifestation.original_title
              else
                row << ""
              end
            when :pub_year
              if item.manifestation && item.manifestation.date_of_publication
                row << item.manifestation.date_of_publication.strftime("%Y")
              else 
                row << ""
              end
            when :publisher
              if item.publisher
                row << item.publisher.delete_if{|p|p.blank?}.join("\t")
              else
                row << ""
              end
            when :carrier_type
              if item.manifestation && item.manifestation.carrier_type
                row << item.manifestation.carrier_type.display_name.localize
              else
                row << ""
              end
            when :shelf
              if item.shelf
                row << item.shelf.display_name.localize
              else
                row << ""
              end
            else
              row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
            end
          end
          output.print '"'+row.join("\"\t\"")+"\"\n"
        end  
      end
    end
  end

  def self.make_item_register_pdf(pdf_file, items)
    if items.nil? || items.size < 1
      logger.warn "item date is empty"
    else
      # pdf
      report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'libcheck_items.tlf') 
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      bookstore_ids = items.inject([]){|ids, item| ids << item.bookstore_id; ids}.uniq! 
      bookstore_ids.each do |bookstore_id|
        report.start_new_page do |page|
          page.item(:date).value(Time.now)
          page.item(:bookstore).value(Bookstore.find(bookstore_id).name) rescue nil
          items.each do |item|
            if item.bookstore_id == bookstore_id
              page.list(:list).add_row do |row|
                row.item(:item_identifier).value(item.item_identifier)
                row.item(:acquired_at).value(item.acquired_at.strftime("%Y%m%d")) if item.acquired_at
                row.item(:patron).value(item.manifestation.creators[0].full_name) if item.manifestation && item.manifestation.creators[0]
                row.item(:title).value(item.manifestation.original_title) if item.manifestation
                row.item(:pub_year).value(item.manifestation.date_of_publication.strftime("%Y")) if item.manifestation && item.manifestation.date_of_publication
                row.item(:publisher).value(item.publisher.delete_if{|p|p.blank?}[0]) if item.publisher
                row.item(:price).value(to_format(item.price)) if item.price
                row.item(:call_number).value(item.call_number)
                row.item(:marc_number).value(item.manifestation.marc_number[0,10]) if item.manifestation && item.manifestation.marc_number
                row.item(:note).value(item.note.split("\r\n")[0]) if item.note
              end
            end
          end	
        end
      end
      report.generate_file(pdf_file)
    end 
    rescue => e
      logger.error "pdf: #{e}"
  end

  def self.make_audio_list_pdf(pdf_file, items)
    if items.nil? || items.size < 1
      logger.warn "item date is empty"
    else
      filename = I18n.t('item_register.audio_list')
      # pdf
      begin
        report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/export_item_lists/item_list"

        report.events.on :page_create do |e|
          e.page.item(:page).value(e.page.no)
        end
        report.events.on :generate do |e|
          e.pages.each do |page|
            page.item(:total).value(e.report.page_count)
          end
        end

        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:list_name).value(filename)
        @items.each do |item|
          report.page.list(:list).add_row do |row|
            row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
            row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
            row.item(:shelf).value(item.shelf.display_name) if item.shelf
            row.item(:ndc).value(item.manifestation.ndc) if item.manifestation
            row.item(:item_identifier).value(item.item_identifier)
            row.item(:call_number).value(item.call_number)
            row.item(:title).value(item.manifestation.original_title) if item.manifestation
          end
        end
        report.generate_file(pdf_file)
        logger.error "created report: #{Time.now}"
        return true
      rescue Exception => e
        logger.error "failed #{e}"
        return false
      end
    end
  end

  def self.make_export_item_list_pdf(items, filename)
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/export_item_lists/item_list"

    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end
    report.start_new_page
    report.page.item(:date).value(Time.now)
    report.page.item(:list_name).value(filename)
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
        row.item(:shelf).value(item.shelf.display_name) if item.shelf
        row.item(:ndc).value(item.manifestation.ndc) if item.manifestation
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:call_number).value(item.call_number)
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_item_list_tsv(items)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:library, 'activerecord.models.library'],
      [:carrier_type, 'activerecord.models.carrier_type'],
      [:shelf, 'activerecord.models.shelf'],
      [:ndc, 'activerecord.attributes.manifestation.ndc'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      ['call_number', 'activerecord.attributes.item.call_number'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << row.join("\t")+"\n"

    items.each do |item|
      row = []
      columns.each do |column|
        case column[0]
        when :library
          row << item.shelf.library.display_name.localize 
        when :carrier_type
          row << item.manifestation.carrier_type.display_name.localize
        when :shelf
          row << item.shelf.display_name
        when :ndc
          row << item.manifestation.ndc
        when :title
          row << item.manifestation.original_title
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end
end

# == Schema Information
#
# Table name: items
#
#  id                          :integer         not null, primary key
#  call_number                 :string(255)
#  item_identifier             :string(255)
#  circulation_status_id       :integer         not null
#  checkout_type_id            :integer         default(1), not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  shelf_id                    :integer         default(1), not null
#  include_supplements         :boolean         default(FALSE), not null
#  checkouts_count             :integer         default(0), not null
#  owns_count                  :integer         default(0), not null
#  resource_has_subjects_count :integer         default(0), not null
#  note                        :text
#  curl                         :string(255)
#  price                       :integer
#  lock_version                :integer         default(0), not null
#  required_role_id            :integer         default(1), not null
#  state                       :string(255)
#  required_score              :integer         default(0), not null
#  acquired_at                 :datetime
#  bookstore_id                :integer
#

