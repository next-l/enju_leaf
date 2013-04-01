# -*- encoding: utf-8 -*-
require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'item')
require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'item') if Setting.operation
class Item < ActiveRecord::Base
  attr_accessible :library_id, :shelf_id, :checkout_type_id, :circulation_status_id,
                  :retention_period_id, :call_number, :bookstore_id, :price, :url, 
                  :include_supplements, :use_restriction_id, :required_role_id, 
                  :acquired_at, :note, :item_identifier, :rank, :remove_reason_id,
                  :use_restriction, :manifestation_id, :manifestation,
                  :shelf_id, :circulation_status, :bookstore, :remove_reason, :checkout_type, 
                  :shelf, :bookstore, :retention_period, :accept_type_id, :accept_type, :required_role,
                  :non_searchable

  self.extend ItemsHelper
  scope :for_checkout, where('item_identifier IS NOT NULL')
  scope :not_for_checkout, where(:item_identifier => nil)
  scope :on_shelf, where('shelf_id != 1')
  scope :on_web, where(:shelf_id => 1)
  scope :for_retain_from_own, lambda{|library| where('shelf_id IN (?)', library.excludescope_shelf_ids).order('created_at ASC')}
  scope :for_retain_from_others, lambda{|library| where('shelf_id NOT IN (?)', library.excludescope_shelf_ids).order('created_at ASC')}
  scope :series_statements_item, lambda {|library_ids, bookstore_ids, acquired_at|
    s = joins(:manifestation => :series_statement, :shelf => :library).
      where(['libraries.id in (?)', library_ids])
    s = s.where(['items.bookstore_id in (?)', bookstore_ids]) if bookstore_ids != :all
    s = s.where(['items.acquired_at >= ?', acquired_at]) if acquired_at.present?
    s
  }
  scope :where_ndcs_libraries_carrier_types, lambda {|ndcs, library_ids, carrier_type_ids|
    tm = Manifestation.arel_table
    tl = Library.arel_table

    ndcs_cond = nil
    (ndcs || []).each do |ndc|
      like = tm[:ndc].matches("#{ndc}%")
      if ndcs_cond.nil?
        ndcs_cond = like
      else
        ndcs_cond = ndcs_cond.or(like)
      end
    end

    s = joins(:manifestation, :shelf => :library)
    s = s.where(tl[:id].in(library_ids).to_sql)
    s = s.where(tm[:carrier_type_id].in(carrier_type_ids).to_sql)
    s = s.where(ndcs_cond.to_sql) if ndcs_cond
    s
  }
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
  belongs_to :remove_reason
  belongs_to :accept_type
  belongs_to :retention_period, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  has_one :item_has_use_restriction, :dependent => :destroy
  has_one :use_restriction, :through => :item_has_use_restriction
  has_many :reserves
  has_many :inter_library_loans, :dependent => :destroy
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  belongs_to :checkout_type
  #belongs_to :resource_import_textresult
  has_many :inventories, :dependent => :destroy
  has_many :inventory_files, :through => :inventories
  has_many :lending_policies, :dependent => :destroy
  has_many :answer_has_items, :dependent => :destroy
  has_many :answers, :through => :answer_has_items
  has_one :resource_import_result
  has_many :libcheck_tmp_items
  has_many :libcheck_notfound_items
  has_many :expenses
  has_many :binding_items, :class_name => 'Item', :foreign_key => 'bookbinder_id'
  belongs_to :binder_item, :class_name => 'Item', :foreign_key => 'bookbinder_id'

  validates_associated :circulation_status, :shelf, :bookstore, :checkout_type, :retention_period
  validates_presence_of :circulation_status, :checkout_type, :retention_period, :rank
  validate :is_original?
  before_validation :set_circulation_status, :on => :create
  before_save :set_use_restriction, :set_retention_period, :check_remove_item, :except => :delete
  after_save :check_price, :except => :delete
  after_save :reindex

  #enju_union_catalog
  has_paper_trail

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher, :library
    string :item_identifier
    string :library
    integer :required_role_id
    integer :circulation_status_id
    integer :accept_type_id
    integer :retention_period_id
    integer :manifestation_id do
      manifestation.id if manifestation
    end
    integer :shelf_id
    integer :patron_ids, :multiple => true
    integer :inventory_file_ids, :multiple => true
    integer :rank
    integer :remove_reason_id
    boolean :non_searchable
    integer :bookbinder_id
    time :created_at
    time :updated_at
  end

  paginates_per 10

  def reindex
    manifestation.try(:index)
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
    return false unless Setting.operation
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
    if self.circulation_status_id == CirculationStatus.find(:first, :conditions => ["name = ?", 'Removed']).id or self.remove_reason
      self.removed_at = Time.zone.now if self.removed_at.nil?
      manifestation = nil
      if self.manifestation
        manifestation = self.manifestation
      else
        manifestation = Manifestation.find(self.manifestation_id)
      end      
      unless manifestation.article?
        self.rank = 1 if self.rank == 0
      end
    else
      self.removed_at = nil
    end
  end

  def check_price
    record = Expense.where(:item_id => self.id).order("id DESC").first
    begin
      unless record.nil?
        record.acquired_at_ym = select_acquired_at
        record.acquired_at = self.acquired_at
        record.save!

        original_library_id = record.budget.library_id rescue nil
        logger.info "@@@@@"
        logger.info "price=#{self.price} / record_price=#{record.price} , library_id=#{self.library_id} / original_library_id=#{original_library_id}"

        if self.price == record.price && self.library_id == original_library_id
          logger.info "no change. price and library_id"
          return
        end
        Expense.transaction do
          Expense.create!(:item_id => self.id, :budget_id => record.budget_id, :price => record.price*-1, :acquired_at_ym  => select_acquired_at, :acquired_at => self.acquired_at)
          #TODO
          budget = Budget.joins(:term).where(:library_id => self.shelf.library.id).order("terms.start_at DESC").first
          if budget
            budget_id = budget.id
          else
            budget_id = nil
          end
          Expense.create!(:item_id => self.id, :budget_id => budget_id, :price => self.price, :acquired_at_ym => select_acquired_at, :acquired_at => self.acquired_at)
        end
      else
        return true if self.price.nil?
        budget = Budget.joins(:term).where(:library_id => self.shelf.library.id).order("terms.start_at DESC").first
        yyyymm = select_acquired_at
        Expense.create!(:item => self, :budget => budget, :price => self.price, :acquired_at_ym => yyyymm, :acquired_at => self.acquired_at)
      end
    rescue Exception => e
      logger.error "Failed to update expense: #{e}"
      logger.error $@
    end
  end

  def is_original?
    if self.rank == 0
      manifestation = nil
      if self.manifestation
        manifestation = self.manifestation
      else
        manifestation = Manifestation.find(self.manifestation_id) rescue nil
      end
      return true if manifestation.nil?
      return errors[:base] << I18n.t('item.original_item_require_item_identidier') unless self.item_identifier

      ranks = manifestation.items.map { |i| i.rank unless i == self }.compact.uniq
      return errors[:base] << I18n.t('item.already_original_item_created') if ranks.include?(0)
    end
  end

  def set_retention_period
    unless self.retention_period
      self.retention_period = RetentionPeriod.find(1)
    end
  end

  def item_bind(bookbinder_id)
    Item.transaction do
      self.bookbinder_id = bookbinder_id
      self.circulation_status = CirculationStatus.where(:name => 'Binded').first
      if self.save
        self.manifestation.index
        return true 
      else
        return false
      end
    end
  end

  # XLSX形式でのエクスポートのための値を生成する
  # ws_type: ワークシートの種別
  # ws_col: ワークシートでのカラム名
  def excel_worksheet_value(ws_type, ws_col)
    helper = Object.new
    helper.extend(ItemsHelper)
    helper.instance_eval { def t(*a) I18n.t(*a) end } # NOTE: ItemsHelper#i18n_rankの中でtを呼び出しているが、ヘルパーを直接利用しようとするとRedCloth由来のtが見えてしまうため、その回避策
    val = nil

    case ws_col
    when 'library'
      val = shelf.library.display_name || ''

    when 'bookstore', 'checkout_type', 'circulation_status', 'required_role'
      val = __send__(ws_col).try(:name) || ''

    when 'accept_type', 'retention_period', 'remove_reason', 'shelf'
      val = __send__(ws_col).try(:display_name) || ''

    when 'acquired_at'
      val = __send__(ws_col).try(:strftime, '%Y-%m-%d') || ''

    when 'rank'
      val = helper.i18n_rank(rank) || ''

    when 'use_restriction'
      val = not_for_loan? ? 'TRUE' : ''

    else
      val = __send__(ws_col) || ''
    end

    val
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
          ['acquired_at', 'activerecord.attributes.item.acquired_at'],
          [:created_at, 'activerecord.attributes.item.created_at'],
          [:call_number, 'activerecord.attributes.item.call_number'],
          [:original_title,'activerecord.attributes.manifestation.original_title'],
          ['removed_at', 'activerecord.models.remove_reason'],
#          ['price', 'activerecord.attributes.item.price'],
          [:patron_publisher,'patron.publisher'], 
          [:patron_creator, 'patron.creator'],
          [:date_of_publication, 'activerecord.attributes.manifestation.date_of_publication'],
          [:removed_reason, 'activerecord.models.remove_reason'],
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
              when "removed_at"
                row << item.removed_at.strftime("%Y/%m/%d") rescue ""
              when "acquired at"
                row << item.acquired_at.strftime("%Y/%m/%d") rescue ""
              when :created_at
                row << item.created_at.strftime("%Y/%m/%d") rescue ""
              when :original_title
                row << item.manifestation.original_title
              when :removed_reason
                row << item.try(:remove_reason).try(:display_name) || "" rescue ""
              when :call_number
                row << item.call_number || "" rescue ""
              when :date_of_publication
                if item.manifestation.date_of_publication.nil?
                  row << ""
                else
                  row << item.manifestation.date_of_publication.strftime("%Y/%m/%d") rescue ""
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
              row.item(:created_at).value(item.created_at.strftime("%Y/%m/%d")) if item.created_at
              row.item(:call_number).value(item.call_number)
              unless item.removed_at.nil?
                row.item(:removed_at).value(item.removed_at.strftime("%Y/%m/%d"))
              end
              row.item(:removed_reason).value(item.remove_reason.display_name) if item.remove_reason
              row.item(:title).value(item.manifestation.original_title)
              unless item.manifestation.date_of_publication.nil?
                #row.item(:date_of_publication).value(item.manifestation.date_of_publication.strftime("%Y/%m/%d"))
              end
              # row.item(:price).value(to_format(item.price))
              row.item(:patron_creator).value(patrons_list(item.manifestation.creators))
              row.item(:patron_publisher).value(patrons_list(item.manifestation.publishers))
              row.item(:date_of_publication).value(item.manifestation.date_of_publication.strftime("%Y/%m")) rescue nil
             end
          end
        end
        report.generate_file(pdf_file)
      end
    end  #end of method
  end

  def self.export_item_register(type, out_dir, file_type = nil) 
    raise "invalid parameter: no path" if out_dir.nil? || out_dir.length < 1
    tsv_file = out_dir + "item_register_#{type}.tsv"
    pdf_file = out_dir + "item_register_#{type}.pdf"
    logger.info "output item_register_#{type} tsv: #{tsv_file} pdf: #{pdf_file}"
    # create output path
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # get item
    if type == 'all'
      @items = Item.order("bookstore_id DESC, acquired_at ASC, item_identifier ASC").all
    else  
      @items = Item.joins(:manifestation).where(["manifestations.manifestation_type_id in (?)", ManifestationType.type_ids(type)]).order("items.bookstore_id DESC, items.acquired_at ASC, items.item_identifier ASC").all
    end
    # make tsv
    make_item_register_tsv(tsv_file, @items) if file_type.nil? || file_type == "tsv"
    # make pdf
    make_item_register_pdf(pdf_file, @items, "item_register_#{type}") if file_type.nil? || file_type == "pdf"
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
  def self.patrons_list(patrons)
    ApplicationController.helpers.patrons_list(patrons, {:nolink => true})
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
      [:call_number, 'activerecord.attributes.item.call_number'],
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
              row << item.try(:bookstore).try(:name) || ""
            when :creator
              creators = item.manifestation.creators.inject([]){|names, creator| names << creator.full_name if creator.full_name; names}.join("\t")
              row << creators || ""
            when :original_title
              row << item.try(:manifestation).try(:original_title) || "" 
            when :pub_year
              pub_year = item.try(:manifestation).try(:date_of_publication).strftime("%Y") rescue nil
              row << pub_year || ""
            when :publisher
              publishers = item.publisher.delete_if{ |p|p.blank? }.join("\t") if item.publisher
              row << publishers || ""
            when :price
              row << item.try(:manifestation).try(:price) || ""
            when :marc_number
              marc_number = item.try(:manifestation).try(:marc_number)[0, 10] rescue nil
              row << marc_number || ""
            when :call_number
              call_number = call_numberformat(item)
              row << call_numberformat(item) || ""
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
      [:call_number, 'activerecord.attributes.item.call_number'],
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
              row << item.try(:shelf).try(:library).try(:display_name).localize || ""
            when :creator
              row << item.manifestation.creators.inject([]){|names, creator| names << creator.full_name if creator.full_name; names}.join("\t") if item.manifestation.creators
            when :original_title
              row << item.try(:manifestation).try(:original_title)
            when :pub_year
              pub_year = item.manifestation.date_of_publication.strftime("%Y") rescue nil
              row << pub_year || ""
            when :publisher
              row << item.publisher.delete_if{|p|p.blank?}.join("\t") if item.publisher
            when :carrier_type
              row << item.try(:manifestation).try(:carrier_type).display_name.localize || ""
            when :shelf
              row << item.try(:shelf).display_name.localize || ""
            when :call_number
              call_number = call_numberformat(item)
              row << call_number || ""
            else
              row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
            end
          end
          output.print '"'+row.join("\"\t\"")+"\"\n"
        end  
      end
    end
  end

  def self.make_item_register_pdf(pdf_file, items, list_title = nil)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'item_register.tlf') 
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
        page.item(:list_title).value(I18n.t("item_register.#{list_title}"))
      end
    end

    bookstore_ids = [nil] + items.inject([]){|ids, item| ids << item.bookstore_id; ids}.uniq!  rescue [nil]
    if bookstore_ids
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
                row.item(:call_number).value(call_numberformat(item)) if item.call_number
                row.item(:marc_number).value(item.manifestation.marc_number[0,10]) if item.manifestation && item.manifestation.marc_number
                row.item(:note).value(item.note.split("\r\n")[0]) if item.note
              end
            end
          end	
        end
      end
    else
      report.start_new_page do |page|
        page.item(:date).value(Time.now)
        page.item(:bookstore).value(nil)
      end
    end
    report.generate_file(pdf_file)
  end

  def self.make_audio_list_pdf(pdf_file, items)
    filename = I18n.t('item_register.audio_list')
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/item_list"

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
        row.item(:call_number).value(call_numberformat(item))
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    report.generate_file(pdf_file)
    logger.error "created report: #{Time.now}"
  end

  def self.make_export_item_list_pdf(items, filename)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/item_list"

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
        row.item(:call_number).value(call_numberformat(item))
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
      [:call_number, 'activerecord.attributes.item.call_number'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

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
        when :call_number
          row << call_numberformat(item)
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  def self.make_export_new_item_list_pdf(items)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/new_item_list"

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
    term = Time.zone.now.months_ago(1).strftime("%Y/%m/%d").to_s + ' -  ' + Time.now.strftime("%Y/%m/%d").to_s
    report.page.item(:term).value(term)
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
        row.item(:shelf).value(item.shelf.display_name) if item.shelf
        row.item(:ndc).value(item.manifestation.ndc) if item.manifestation
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:call_number).value(call_numberformat(item))
        row.item(:created_at).value(item.created_at.strftime("%Y/%m/%d"))
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_new_item_list_tsv(items)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # set term
    term = Time.zone.now.months_ago(1).strftime("%Y/%m/%d").to_s + ' -  ' + Time.now.strftime("%Y/%m/%d").to_s
    data << '"' + term + "\"\n"

    columns = [
      [:library, 'activerecord.models.library'],
      [:carrier_type, 'activerecord.models.carrier_type'],
      [:shelf, 'activerecord.models.shelf'],
      [:ndc, 'activerecord.attributes.manifestation.ndc'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      [:call_number, 'activerecord.attributes.item.call_number'],
      [:created_at, 'activerecord.attributes.item.created_at'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

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
        when :created_at
          row << item.created_at.strftime("%Y/%m/%d") if item.created_at
        when :call_number
          row << call_numberformat(item)
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  def self.make_export_removed_list_pdf(items)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/removed_list"

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
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
        row.item(:shelf).value(item.shelf.display_name) if item.shelf
        row.item(:remove_reason).value(item.remove_reason.display_name) if item.remove_reason
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:call_number).value(call_numberformat(item))
        row.item(:removed_at).value(item.removed_at.strftime("%Y/%m/%d")) if item.removed_at
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_removed_list_tsv(items)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    columns = [
      [:library, 'activerecord.models.library'],
      [:carrier_type, 'activerecord.models.carrier_type'],
      [:shelf, 'activerecord.models.shelf'],
      [:ndc, 'activerecord.attributes.manifestation.ndc'],
      [:remove_reason, 'activerecord.models.remove_reason'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      [:call_number, 'activerecord.attributes.item.call_number'],
      [:removed_at, 'activerecord.attributes.item.removed_at'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

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
        when :removed_at
          row << item.removed_at.strftime("%Y/%m/%d") rescue ""
        when :remove_reason
          row << item.try(:remove_reason).try(:display_name) || "" rescue ""
        when :call_number
          row << item.call_number || ""
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  def self.make_export_new_book_list_pdf(items)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/new_book_list"

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
    date_ago = Time.zone.now - SystemConfiguration.get("new_book_term").day 
    term = date_ago.strftime("%Y/%m/%d").to_s + ' -  '
    report.page.item(:term).value(term)
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:carrier_type).value(item.manifestation.carrier_type.display_name.localize) if item.manifestation && item.manifestation.carrier_type
        row.item(:shelf).value(item.shelf.display_name) if item.shelf
        row.item(:ndc).value(item.manifestation.ndc) if item.manifestation
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:pub_date).value(item.manifestation.pub_date)
        row.item(:acquired_at).value(item.acquired_at.strftime("%Y/%m/%d")) if item.acquired_at
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_new_book_list_tsv(items)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # set term
    date_ago = Time.zone.now - SystemConfiguration.get("new_book_term").day 
    term = date_ago.strftime("%Y/%m/%d").to_s + ' -  '
    data << '"' + term + "\"\n"

    columns = [
      [:library, 'activerecord.models.library'],
      [:carrier_type, 'activerecord.models.carrier_type'],
      [:shelf, 'activerecord.models.shelf'],
      [:ndc, 'activerecord.attributes.manifestation.ndc'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      [:pub_date, 'activerecord.attributes.manifestation.pub_date'],
      [:acquired_at, 'activerecord.attributes.item.acquired_at'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

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
        when :pub_date
          row << item.manifestation.pub_date
        when :acquired_at
          acquired_at = ""
          acquired_at =  item.acquired_at.strftime("%Y/%m/%d") if item.acquired_at
          row << acquired_at
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  def self.make_export_series_statements_latest_list_pdf(items)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/series_statements_latest_list"

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
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:acquired_at).value(item.acquired_at.strftime("%Y/%m/%d")) if item.acquired_at
        row.item(:bookstore).value(item.bookstore.name) if item.bookstore
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:volume_number_string).value(item.manifestation.volume_number_string) if item.manifestation
        row.item(:issue_number_string).value(item.manifestation.issue_number_string) if item.manifestation
        row.item(:serial_number_string).value(item.manifestation.serial_number_string) if item.manifestation
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_series_statements_latest_list_tsv(items)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    columns = [
      [:library, 'activerecord.models.library'],
      [:acquired_at, 'activerecord.attributes.item.acquired_at'],
      [:bookstore, 'activerecord.models.bookstore'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      [:volume_number_string, 'activerecord.attributes.manifestation.volume_number_string'],
      [:issue_number_string, 'activerecord.attributes.manifestation.issue_number_string'],
      [:serial_number_string, 'activerecord.attributes.manifestation.serial_number_string'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    items.each do |item|
      row = []
      columns.each do |column|
        case column[0]
        when :library
          row << item.shelf.library.display_name.localize 
        when :acquired_at
          row << item.acquired_at.strftime("%Y/%m/%d") || "" rescue ""
        when :bookstore
          bookstore = ""
          bookstore = item.bookstore.name if item.bookstore and item.bookstore.name
          row << bookstore
        when :volume_number_string
          row << item.manifestation.volume_number_string || "" rescue ""
        when :issue_number_string
          row << item.manifestation.issue_number_string || "" rescue ""
        when :serial_number_string
          row << item.manifestation.serial_number_string || "" rescue ""
        when :title
          row << item.manifestation.original_title || "" rescue ""
        else
          row << get_object_method(item, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  def self.make_export_series_statements_list_pdf(items, acquired_at)
    return false if items.blank?
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/report/series_statements_list"

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
    if acquired_at.size > 0
      start_date = Time.zone.parse(acquired_at).strftime("%Y/%m/%d").to_s
    else
      start_date = ""
    end
    term = start_date + ' - ' + Time.now.strftime("%Y/%m/%d").to_s
    report.page.item(:term).value(term)
    items.each do |item|
      report.page.list(:list).add_row do |row|
        row.item(:library).value(item.shelf.library.display_name.localize) if item.shelf && item.shelf.library
        row.item(:acquired_at).value(item.acquired_at.strftime("%Y/%m/%d")) if item.acquired_at
        row.item(:bookstore).value(item.bookstore.name) if item.bookstore
        row.item(:item_identifier).value(item.item_identifier)
        row.item(:volume_number_string).value(item.manifestation.volume_number_string) if item.manifestation
        row.item(:issue_number_string).value(item.manifestation.issue_number_string) if item.manifestation
        row.item(:serial_number_string).value(item.manifestation.serial_number_string) if item.manifestation
        row.item(:title).value(item.manifestation.original_title) if item.manifestation
      end
    end
    return report
  end

  def self.make_export_series_statements_list_tsv(items, acquired_at)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # set term
    if acquired_at.size > 0
      start_date = Time.zone.parse(acquired_at).strftime("%Y/%m/%d").to_s
    else
      start_date = ""
    end
    term = start_date + ' - ' + Time.now.strftime("%Y/%m/%d").to_s
    data << '"' + term + "\"\n"

    columns = [
      [:library, 'activerecord.models.library'],
      [:acquired_at, 'activerecord.attributes.item.acquired_at'],
      [:bookstore, 'activerecord.models.bookstore'],
      ['item_identifier', 'activerecord.attributes.item.item_identifier'],
      [:volume_number_string, 'activerecord.attributes.manifestation.volume_number_string'],
      [:issue_number_string, 'activerecord.attributes.manifestation.issue_number_string'],
      [:serial_number_string, 'activerecord.attributes.manifestation.serial_number_string'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    items.each do |item|
      row = []
      columns.each do |column|
        case column[0]
        when :library
          row << item.shelf.library.display_name.localize 
        when :acquired_at
          row << item.acquired_at.strftime("%Y/%m/%d") if item.acquired_at
        when :bookstore
          bookstore = ""
          bookstore = item.bookstore.name if item.bookstore and item.bookstore.name
          row << bookstore
        when :volume_number_string
          row << item.manifestation.volume_number_string
        when :issue_number_string
          row << item.manifestation.issue_number_string
        when :serial_number_string
          row << item.manifestation.serial_number_string
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

  def self.make_export_item_list_job(file_name, file_type, method, dumped_query, args, user)
    job_name = GenerateItemListJob.generate_job_name
    Delayed::Job.enqueue GenerateItemListJob.new(job_name, file_name, file_type, method, dumped_query, args, user)
    job_name
  end

  class GenerateItemListJob
    include Rails.application.routes.url_helpers
    include BackgroundJobUtils

    def initialize(job_name, file_name, file_type, method, dumped_query, args, user)
      @job_name = job_name
      @file_name = file_name
      @file_type = file_type
      @method = method
      @dumped_query = dumped_query
      @args = args
      @user = user
    end
    attr_accessor :job_name, :file_name, :file_type, :method, :dumped_query, :args, :user

    def perform
      user_file = UserFile.new(user)

      # get data
      query = Marshal.load(dumped_query)
      logger.info "SQL start at #{Time.now}"
      items = query.all
      logger.info "SQL end at #{Time.now}\nfound #{items.length rescue 0} records"
      logger.info "list_type=#{file_name} file_type=#{file_type}"

      data = Item.__send__("#{method}_#{file_type}", items, *args)
      if file_type == 'pdf'
        raise I18n.t('item_list.no_record') unless data
        data = data.generate
      end

      io, info = user_file.create(:item_list, "#{file_name}.#{file_type}")
      begin
        io.print data
      ensure
        io.close
      end

      url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
      message(
        user,
        I18n.t('item_list.export_job_success_subject', :job_name => job_name),
        I18n.t('item_list.export_job_success_body', :job_name => job_name, :url => url))

    rescue => exception
      message(
        user,
        I18n.t('item_list.export_job_error_subject', :job_name => job_name),
        I18n.t('item_list.export_job_error_body', :job_name => job_name, :message => exception.message))
    end
  end

  def self.make_export_register_job(file_name, file_type, method, args, user)
    job_name = GenerateItemRegisterJob.generate_job_name
    Delayed::Job.enqueue GenerateItemRegisterJob.new(job_name, file_name, file_type, method, args, user)
    job_name
  end

  class GenerateItemRegisterJob
    include Rails.application.routes.url_helpers
    include BackgroundJobUtils

    def initialize(job_name, file_name, file_type, method, args, user)
      @job_name = job_name
      @file_name = file_name
      @file_type = file_type
      @method = method
      @args = args
      @user = user
    end
    attr_accessor :job_name, :file_name, :file_type, :method, :args, :user

    def perform
      fn = "#{file_name}.#{file_type}"
      user_file = UserFile.new(user)
      url = nil

      logger.error "SQL start at #{Time.now}"

      Dir.mktmpdir do |tmpdir|
        Item.__send__(method, *args, tmpdir + '/', file_type)

        o, info = user_file.create(:item_register, fn)
        begin
          open(File.join(tmpdir, fn)) do |i|
            FileUtils.copy_stream(i, o)
          end
        ensure
          o.close
        end

        url = my_account_url(:filename => info[:filename], :category => info[:category], :random => info[:random])
      end

      message(
        user,
        I18n.t('item_register.export_job_success_subject', :job_name => job_name),
        I18n.t('item_register.export_job_success_body', :job_name => job_name, :url => url))

      logger.error "created report: #{Time.now}"

    rescue => exception
      message(
        user,
        I18n.t('item_register.export_job_error_subject', :job_name => job_name),
        I18n.t('item_register.export_job_error_body', :job_name => job_name, :message => exception.message))
    end
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

