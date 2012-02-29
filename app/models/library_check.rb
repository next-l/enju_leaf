class LibraryCheck < ActiveRecord::Base
      scope :now_processing, where(:state => 'started')
      validates_presence_of :opeym
      attr_accessor :shelf_upload_file_name, :file_update_flg
      has_attached_file :shelf_upload, :path => ":rails_root/private:url"
      validates_attachment_presence :shelf_upload, :message => I18n.t('activerecord.errors.messages.not_selected'), :if => :file_update_flg
      before_save { self.shelf_def_file = self.shelf_upload_file_name unless self.shelf_upload_file_name.nil?}
      has_many :libcheck_data_files, :foreign_key => 'library_check_id'
      has_one :library_check_shelf, :foreign_key => 'id'
      validates_length_of :opeym, :maximum => 6, :minimum => 6
      validates_numericality_of :opeym

  # CONSTANT : for NDC
  PARENTHESIS_PATTERN_1 = "^\\((.+)\\)(.+)$" # "(xx) yyy" pattern
  PARENTHESIS_PATTERN_2 = "^(.+)\\((.+)\\)$" # "xxx (yy)" pattern
  NDC_TYPE_0 = 0 # unknown
  NDC_TYPE_A = 1 # \d\d\d.\d\d\d.\d\d\d or \d\d\d.\d\d or \d\d\d
  NDC_TYPE_B = 2 # [R]\d\d\d\d
  NDC_TYPE_C = 3 # [A|B|C|D|E|F|G]\d\d\d
  NDC_TYPE_D = 4 # else

  def delayed_import(file_fullpath)
    import(file_fullpath)
    import_file = file_fullpath.gsub(/\/.+\//,'')
    pdf_file = import_file.gsub(/\..+?$/,'.pdf')
    basedir = file_fullpath.gsub(/\/[^\/]+$/,'/')
    create_pdf(basedir, pdf_file)
  end

  def delayed_exec(dir_base)
    execute_process(dir_base)
  end

  def import(filepath)
    logger.info("START: import shelf definition file")
    logger.info("path: " + filepath)
    file = CSV.open(filepath, :col_sep => "\t")
    header = file.first
    rows = CSV.open(filepath, :headers => header, :col_sep => "\t")
    file.close
    field = rows.first
    if [field['shelfid'], field['stackid'], field['gid']].reject{|field| field.to_s.strip == ""}.empty?
      raise "You should specify shelfid, stackid or gid in the first line"
    end
    LibcheckShelf.destroy_all
    rows.each_with_index do |row, index|
      next if row['shelfid'].blank? # 2011.06.28 for ticket 1232
      begin
        LibcheckShelf.create(
          :shelf_name => NKF.nkf('-Sw', row['shelfid']),
          :stack_id =>  NKF.nkf('-Sw', row['stackid']),
          :shelf_grp_id => NKF.nkf('-Sw', row['gid'])
        )
      rescue => exc
        logger.info("shelf data import failed: column " + index.to_s)
        logger.info(exc)
        raise exc
      end
    end
  end

  def create_pdf(basedir,filename)
      logger.debug("create_pdf")
      code_type = "Code128B"
      libcheck_shelves = LibcheckShelf.all
      words = []
      libcheck_shelves.each do |libcheck_shelf|
        words << libcheck_shelf.shelf_name
      end
      barcode_sheet = BarcodeSheet.new
      barcode_sheet.path = basedir
      barcode_sheet.code_type = code_type
      barcode_sheet.create_jpgs(words)
      barcode_sheet.create_pdf(filename+"~")
      File.rename(basedir+filename+"~",basedir+filename)
      return basedir + filename
    rescue => exc
      logger.error("barcode pdf create failed: "+basedir+filename)
      logger.info(exc)
      if File.exist?(basedir+filename+"~")
        File.delete(basedir+filename+"~")
      end
  end

  #------------------------------------------------------------------------
  # for library_check batch process

  # library check main for batch
  def self.start_check(libcheck_id)
    p "#{Time.zone.now} start library check target id is #{libcheck_id}"

    # get target library_check object
    libcheck = LibraryCheck.find(libcheck_id) rescue libcheck = nil
    if libcheck.nil? then
      logger.info "There is no libaray check target."
    else
      #libcheck.exec_process
      if libcheck.preprocess?(false)
        p "library check pre-process is success"
        dir_base = "#{Rails.root}/private/system"
        libcheck.execute_process(dir_base)
      else
        p "library check pre-process is failed"
      end
    end
  rescue => exc
    p "error : " + exc.to_s
  end
  # end_of_start_check

  # START FOR CONFUSION METHOD TEST
  def self.confusion_test
    libcheck = LibraryCheck.new
    libcheck.exec_confusion
  end

  def exec_confusion
    check_confusion
  end
  # END FOR CONFUSION METHOD TEST


  # This method is called from controller 
  # library check process 1
  def preprocess?(do_delay = true)
    in_processing = LibraryCheck.now_processing;
    if !in_processing.nil? && !in_processing.empty? then
      logger.info "There is processing other check : #{in_processing.size}"
      in_processing.each do |in_p|
        logger.info "Processing: #{in_p.opeym}"
      end
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.othher_active_process')
      sm_fail!
      return false
    end
p "start library check main process for #{self.id}"

    dir_base = "#{Rails.root}/private/system"

    #check execute conditions
    #1-1) status library_check is ready ?
    p self.shelf_upload
    logger.debug "current state is => #{self.state}"
    if self.state == "pending" then
      self.error_msg = ""
      self.operated_at = Time.now
      sm_start!
    elsif self.state != "started" then
      logger.info "trying to retry library check of #{self.id}"
      self.error_msg = ""
      self.operated_at = Time.now
      sm_retry!
    else
      t_msg = "target library check is not ready to do check: #{self.state}"
      p t_msg
      logger.warn t_msg
      self.error_msg = t_msg
      return false
    end

    # check status: ready to start process
    unless ready_status_check?
      #self.save!
      sm_fail!
      return false
    end
p "ready status is OK"

    # delayed process
    send_later(:delayed_exec, dir_base) if do_delay

    return true
  end
  # end_of_preprocess

  # ---------------------------------------------------------------
  # This method is invoked as delayed_job
  # library check main process
  def execute_process(dir_base)
    raise "parameter error: base directory is null" if dir_base.blank?
    logger.info "start LibraryCheck.execute : #{dir_base}"

    #1-3) item barcord data is uploaded ?
    data_files = self.libcheck_data_files
    data_files = [] if data_files.nil? # this check is already done

    barcord_files = []
    data_files.each do |f|
      in_file = "#{dir_base}/data_uploads/#{f.id}/original/#{f.file_name}"
      if File.exist?(in_file) then
        barcord_files << in_file
        logger.debug "#{f.file_name} is found"
      else
        logger.warn "#{f.file_name} is NOT found"
      end
    end

    logger.info "start load check barcode data"
    #2) load barcode data to libcheck_tmp_items table
    begin
      load_check_barcode_data(barcord_files)
    rescue => exc
      p "Error at loading barcord files" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_loading_barcode') + ":" + exc.to_s
      logger.error "Error at loading barcode files:" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end load check barcode data"

    do_notfound_flg = configatron.libcheck_test_do_notfound
    logger.info "don't check not found" unless do_notfound_flg

    logger.info "start check not found items"
    #3) search not found item information
    begin
      check_notfound_items() if do_notfound_flg
    rescue => exc
      #p "Error at finding not found items" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_checking_notfound') + ":" + exc.to_s
      logger.error "Error at search not found items:" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end check not found items"
    
    #4-pre) auto checkin
    logger.info "start auto_checkin #{SystemConfiguration.get("library_checks.auto_checkin")}"
    if SystemConfiguration.get("library_checks.auto_checkin") 
      begin
        logger.info "start auto_checkin"
        check_checkouted_items_with_checkin   
        logger.info "end auto_checkin"
      rescue => exc
        logger.error "Error occured. at check_checkouted_items_with_checkin:" + exc.to_s
        logger.error $@
      end
    end
    logger.info "end auto_checkin "

    logger.info "start check confusion"
    #4) check confusion
    begin
      check_confusion()
    rescue => exc
      #p "Error at checking confusion:" + exc.to_s
      logger.error "Error at checking confusion:" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_checking_confusion') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end check confusion"
    
    # output directory
    out_dir = "#{dir_base}/library_check/#{self.id}/"
    # clear output directory
    Dir.foreach(out_dir){|file| File.delete(out_dir + file) rescue nil} rescue nil

    logger.info "start export resource list"
    #5) output resource list
    begin
      LibcheckTmpItem.export(out_dir)
    rescue => exc
      p "Error at exporting resource list:" + exc.to_s
      logger.error "Error at exporting resource list:" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_resource_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export resource list"


    logger.info "start export resource list (pdf)"
    #5-2) output resource list (pdf)
    begin
      LibcheckTmpItem.export_pdf(out_dir)
    rescue => exc
      p "Error at exporting resource list (pdf):" + exc.to_s
      logger.error "Error at exporting resource list (pdf):" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_resource_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export resource list"

   logger.info "start export error list (csv,pdf)"
    #5-3) output error list (csv,pdf)
    begin
      LibcheckTmpItem.export_error_list(out_dir)
    rescue => exc
      p "Error at exporting error list (csv,pdf):" + exc.to_s
      p "Error at export_removing_list (csv,pdf):" + $@
      logger.error "Error at exporting error list (csv,pdf):" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_error_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export resource list"

    logger.info "start export not found item list"
    #6) output not found item list
    begin
      LibcheckNotfoundItem.export(out_dir)
    rescue => exc
      p "Error at exporting not found item list:" + exc.to_s
      p "Error at export_removing_list (csv,pdf):" + $@
      logger.error "Error at exporting not found item list:" + exc.to_s
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_notfound_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export not found item list"

    #7) 
    logger.info "start export_removing_list"
    begin 
      Item.export_removing_list(out_dir)
    rescue => exc
      p "Error at export_removing_list (csv,pdf):" + exc.to_s
      p "Error at export_removing_list (csv,pdf):" + $@
      logger.error "Error at exporting error list (csv,pdf):" + exc.to_s
      logger.error "Error at exporting error list (csv,pdf):" + $@
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_error_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export_removing_list"
    
    #8) export item register
    logger.info "start export_item_register"
    begin
      Item.export_item_register(out_dir)
    rescue => exc
      p "Error at export_item_register (csv,pdf):" + exc.to_s
      p "Error at export_item_register (csv,pdf):" + $@
      logger.error "Error at exporting item register (csv,pdf):" + exc.to_s
      logger.error "Error at exporting item register (csv,pdf):" + $@
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_item_register') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export_item_register"  

    #9) export detection item list
    logger.info "start export_detection_list"
    begin
      LibcheckDetectionItem.export_detection_list(out_dir)
    rescue => exc
      p "Error at export_detection_list (csv,pdf):" + exc.to_s
      p "Error at export_detection_list (csv,pdf):" + $@
      logger.error "Error at exporting detection list (csv,pdf):" + exc.to_s
      logger.error "Error at exporting detection list (csv,pdf):" + $@
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.error_at_exporting_detection_list') + ":" + exc.to_s
      sm_fail!
      return
    end
    logger.info "end export_detection_list"  

    self.operated_at = Time.now
    sm_complete!
  rescue => exc
    logger.error exc
    self.error_msg = exc.to_s
    sm_fail!
  end
  # end_of_preprocess

  def check_checkouted_items_with_checkin
    logger.info("start check_checkouted_items_with_checkin") 

    LibcheckStatusChangedItem.destroy_all

    librarians = {} 
    User.librarians.each { |user| librarians[user.library.id] = user } 
    #puts librarians

    names = ['On Loan']
    ids = CirculationStatus.select(:id).where(:name => names).map(&:id)

    checkout_found_items = Item.find_by_sql(
      "select id, item_identifier, circulation_status_id, checkout_type_id" +
      " from items where id in (" +
      " select item_id from libcheck_tmp_items where item_id is not null)" +
      " AND items.deleted_at is null" +
      " AND items.circulation_status_id in (#{ids.join(',').chomp(',')})" +
      " AND items.id in (select item_id from checkouts where checkin_id is null)" +
      " order by items.item_identifier, items.id")

    if checkout_found_items.nil? then
      logger.info "There is no checkouted items"
    else
      logger.info "#{checkout_found_items.length} items are found."
      checkout_found_items.each do |item|
        logger.debug "checkouted => id: #{item.id}, item_identifier: #{item.item_identifier}, status: #{item.circulation_status_id}"

        nitem = LibcheckStatusChangedItem.new

        @item_tmp = Item.find(item.id)
        #TODO 
        #shelf_id = @item_tmp.libcheck_tmp_items.first.shelf_id
        #library_id = Shelf.find(shelf_id).library.id

        library_id = @item_tmp.shelf.library.id
        logger.debug "library_id: #{library_id}"

        @basket = nil
        if librarians[library_id]
          user = librarians[library_id]
          #@user = User.find(user_id)
          @basket = Basket.new(:user => user)
          @basket.save!(:validate => false)
          @checkin = @basket.checkins.new(:item_id => @item_tmp.id, :librarian_id => user.id)
          @checkin.item = @item_tmp
          if @checkin.save(:validate => false)
            item_messages = @checkin.item_checkin(user)
            #p item_messages
            #logger.warn("failed save checkin.")
            #nitem.completed = false
          end
        else
          logger.warn("not find librarian library_id: #{library_id} shelf_id: #{shelf_id} item_id: #{item.id}")
          nitem.completed = false
        end

        nitem.item_id = item.id
        nitem.item_identifier = item.item_identifier
        nitem.circulation_status_id = item.circulation_status_id
        nitem.save
      end
    end
    logger.info("end check_checkouted_items_with_checkin") 
  end

  # load barcode information
  def load_check_barcode_data(file_list)
    raise "parameter error: file_list is nil" if file_list.nil?
    
    LibcheckTmpItem.destroy_all # clear library check tmp items table
    file_list.each do |f|
      #p "loading input file: #{f}"
      logger.debug "loading input file: #{f}"
      LibcheckTmpItem.import(f)
    end
  end
  # end_of_load_check_barcode_data

  # check lack items
  private
  def check_notfound_items
    # clear not found items table
    LibcheckNotfoundItem.destroy_all

    s_name = configatron.libcheck_serial_name
    s_type = CheckoutType.find_by_name(s_name) rescue nil
    s_id = s_type.nil? ? 0:s_type.id
    logger.info "checkout type id of the serial => #{s_id}"

    check_lost_items(s_id)
    check_checkouted_items(s_id)
  end
  # end_of_check_notfound_items

  # check lost items
  private
  def check_checkouted_items(serial_id = 0)
    s_id = serial_id

    # if exclude checkouting items, add following condition to the select.
    # difference between lost items is checkouted item's id in checkouts table
    notfound_items = Item.find_by_sql(
      "select id, item_identifier, checkout_type_id" +
      " from items where id not in (" +
      " select item_id from libcheck_tmp_items where item_id is not null)" +
      " AND deleted_at is null" +
      " AND id in (select item_id from checkouts where checkin_id is null)" +
      " order by item_identifier, id")
    if notfound_items.nil? then
      logger.info "There is no checkouted items"
    else
      logger.info "#{notfound_items.length} items are not found."
      notfound_items.each do |ni|
        logger.debug "checkouted => id: #{ni.id}, item_identifier: #{ni.item_identifier}"

        nitem = LibcheckNotfoundItem.new
        nitem.item_id = ni.id
        nitem.item_identifier = ni.item_identifier
        nitem.status = LibcheckNotfoundItem::STS_CHECKOUT

        nitem.save
      end
    end
  end
  # end_of_check_lack_items

  # check lost items
  private
  def check_lost_items(serial_id = 0)
    s_id = serial_id

    # if exclude checkouting items, add following condition to the select.
    notfound_items = Item.find_by_sql(
      "select id, item_identifier, checkout_type_id" +
      " from items where id not in (" +
      " select item_id from libcheck_tmp_items where item_id is not null)" +
      " AND deleted_at is null" +
      " AND id NOT in (select item_id from checkouts where checkin_id is null)" +
      " order by item_identifier, id")
    if notfound_items.nil? then
      logger.info "There is no lost items"
    else
      logger.info "#{notfound_items.length} items are not found."
      notfound_items.each do |ni|
        logger.debug "not found => id: #{ni.id}, item_identifier: #{ni.item_identifier}"

        # ignore empty item_identifier
        next if ni.item_identifier.blank?

        nitem = LibcheckNotfoundItem.new
        nitem.item_id = ni.id
        nitem.item_identifier = ni.item_identifier
        nitem.status = LibcheckNotfoundItem::STS_NORMAL

        #TODO: anything else?
        #p nitem

        nitem.save
      end
    end
  end
  # end_of_check_lost_items

  # check confusion
  private
  def check_confusion
    logger.info "start check confusion"
    shelves = LibcheckShelf.all(:order => 'id')
    shelves = [] if shelves.nil?

    logger.info "shelf count: #{shelves.length}"
    shelves.each do |shelf|
      check_confusion_in_shelf(shelf)
    end

  end
  # end_of_check_confusion

  private
  def check_confusion_in_shelf(shelf)
    raise "parameter error: shelf is nil" if shelf.nil?

    # min 
    outskirts_cnt = configatron.libcheck_outskirts_count
    outskirts_cnt = 2 if outskirts_cnt.nil?
    logger.info "start confusion check in shelf => #{shelf.shelf_name}"

    books = LibcheckTmpItem.find(:all,
              #:select => 'id,item_identifier,item_id,ndc,class_type2,shelf_id',
              :conditions => ['shelf_id = ?', shelf.id],
              :order => 'no, id')
    books = [] if books.nil?
    logger.info "books count in #{shelf.shelf_name} => #{books.length}"
    if books.empty? then
      logger.info "There is no books in #{shelf.shelf_name}"
    elsif books.length == 1 then
      logger.info "There is only a book in #{shelf.shelf_name}"
    else
      logger.info "start check confution : #{shelf.shelf_name}"
      min_cnt = configatron.libcheck_disorder_count rescue 3
      b_first = books[0]
      b_end = books[books.length-1]
      logger.debug "first : #{b_first.item_identifier}"
      logger.debug "end   : #{b_end.item_identifier}"
      item = nil
      books.each do |book|
        unless book.item_id.nil?
          item = Item.find(book.item_id)
          break unless item.nil?
        end
      end
      if item.nil? then
        logger.warn "there is no exist item in #{shelf.shelf_name}"
        return
      end

      # checkout_type
      # use => is there an items which has different checkout_type_id ?
      t_checkout_type = item.checkout_type
      logger.info "checkout_type:#{t_checkout_type.id}=>#{t_checkout_type.name}"

      # is NDC check target?
      chk_ndc = check_ndc_type?(t_checkout_type.name)
      logger.info "check_ndc_type? => #{chk_ndc}"

      ndc_hash = Hash.new
      ndc_types = Hash.new
      books.each do |book|
        # in this case: already not_found flag is checked
        next if book.item_id.nil?

        t_item = Item.find(book.item_id)
        if t_item.nil? then
          book.status_flg |= LibcheckTmpItem::STS_NOT_FOUND
          next
        end

        t_ndc = fix_ndc(book.ndc)
        logger.debug book.item_identifier + " -> " + t_ndc.to_s
#p book.item_identifier + " -> " + t_ndc.to_s
        unless t_ndc.nil?
          ndc_hash[book.id.to_s] = t_ndc

          ndc_types[t_ndc[:type].to_s] = 0 if ndc_types[t_ndc[:type].to_s].nil?
          ndc_types[t_ndc[:type].to_s] += 1
        end
#p book.item_identifier + " => " + t_ndc.to_s

        if t_item.checkout_type_id != t_checkout_type.id then
          logger.info "DIFF_CHECKOUT_TYPE: #{book.item_identifier}"
          book.status_flg |= LibcheckTmpItem::STS_CHECKOUT_T_DIFF
          book.confusion_flg = LibcheckTmpItem::CONFUSION_FLG
          next
        end
      end

      #
      check_ndc_minority(books, ndc_hash, ndc_types, outskirts_cnt)
      #
      check_ndc_range(books, ndc_hash, ndc_types, outskirts_cnt) if chk_ndc

      # update libcheck_tmp_items
      books.each do |book|
        book.save!
      end

    end # end books is not empty and only an item
  end
  # end_of_check_confusion_in_shelf(shelf)

  # check minority ndc type
  private
  def check_ndc_minority(books, ndc_hash, ndc_types, outskirts_cnt)
    logger.info "start NDC minotiry check"
    return if books.nil? || ndc_hash.nil? || ndc_types.nil?

    outskirts_cnt = 2 if outskirts_cnt.nil?

    books.each do |book|
      next if book.item_id.nil?

      t_ndc = ndc_hash[book.id.to_s]
      next if t_ndc.nil?

      cnt = ndc_types[t_ndc[:type].to_s]
      if !cnt.nil? && ndc_types.size > 1 && cnt <= outskirts_cnt
        logger.info "MINOR_NDC_TYPE 1: #{book.item_identifier}"
        book.status_flg |= LibcheckTmpItem::STS_NDC_WARNING
        book.confusion_flg = LibcheckTmpItem::CONFUSION_FLG
      end
    end
  end

  # check ndc range
  private
  def check_ndc_range(books, ndc_hash, ndc_types, outskirts_cnt)
    logger.info "start NDC range check"
    return if books.nil? || ndc_hash.nil? || ndc_types.nil?

    outskirts_cnt = 2 if outskirts_cnt.nil?

    t0_cnt = my_to_i(ndc_types[NDC_TYPE_0.to_s])
    t1_cnt = my_to_i(ndc_types[NDC_TYPE_A.to_s])
    logger.info "type 0 count -> #{t0_cnt}"
    logger.info "type A count -> #{t1_cnt}"

    first_b = find_first_has_ndc(books, ndc_hash)
    last_b  = find_last_ndc(books, ndc_hash)
    ndc_f = ndc_hash[first_b.id.to_s] unless first_b.nil?
    ndc_l = ndc_hash[last_b.id.to_s] unless last_b.nil?
    can_check_range = !ndc_f.nil? && !ndc_l.nil?

    books.each do |book|
      next if book.item_id.nil?

      t_ndc = ndc_hash[book.id.to_s]
      if t_ndc.nil?
        logger.error "NDC value is null -> #{book.item_identifier}"
        next
      end

      if t_ndc[:type] == NDC_TYPE_0 && t1_cnt > outskirts_cnt
        logger.info "MINOR_NDC_TYPE 2: #{book.item_identifier}"
        book.status_flg |= LibcheckTmpItem::STS_NDC_WARNING
        book.status_flg |= LibcheckTmpItem::STS_INVALID_CALL_NO
        book.confusion_flg = LibcheckTmpItem::CONFUSION_FLG
      end

      if t1_cnt > outskirts_cnt && t_ndc[:type] == NDC_TYPE_A && can_check_range
        if t_ndc[:ndc_1] >= ndc_f[:ndc_1] && t_ndc[:ndc_1] <= ndc_l[:ndc_1]
          #p "OK -> #{book.item_identifier}"
        else
          logger.info "OUT_OF_RANGE: #{book.item_identifier}"
          book.confusion_flg = LibcheckTmpItem::CONFUSION_FLG
        end
      end
    end
  end

  private
  def my_to_i(val)
    return val.nil? ? 0:val
  end

  private
  def find_first_has_ndc(books, ndc_hash)
    return nil if books.nil? || ndc_hash.nil?

    ret = nil
    books.each do |book|
      t_ndc = ndc_hash[book.id.to_s]
      next if t_ndc.nil?
      next if t_ndc[:type] != NDC_TYPE_A

      ret = book
      break;
    end

    return ret
  end
  private
  def find_last_ndc(books, ndc_hash)
    return nil if books.nil? || ndc_hash.nil?

    ret = nil
    books.reverse_each do |book|
      t_ndc = ndc_hash[book.id.to_s]
      next if t_ndc.nil?
      next if t_ndc[:type] != NDC_TYPE_A

      ret = book
      break;
    end

    return ret
  end


  # state transition
  state_machine :initial => :pending do
    event :sm_start do
      transition :pending => :started
    end

    event :sm_retry do
      transition :completed => :started
      transition :failed => :started
    end

    event :sm_complete do
      transition :started => :completed
    end

    event :sm_fail do
      transition :started => :failed
    end
  end

  # check the library_check definition is ready
  private
  def ready_status_check?
    #1) shelf definition is uploaded ?
    dir_base = "#{Rails.root}/private/system"
    shelf_def = "#{dir_base}/shelf_uploads/#{self.id}/original/#{self.shelf_def_file}"
    logger.debug "shelf def file #{shelf_def}"
    unless File.exist?(shelf_def)
      p "There is no shelf definition file."
      Rails.logger.error "There is no shelf definition file."
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.no_shelf_definition_file')
      return false
    end

    #2) item barcord data is uploaded ?
    files_exists = false
    data_files = self.libcheck_data_files
    if data_files.nil? || data_files.empty? then
      p "there is no data files for library_check(#{self.id})"
      logger.warn "No data files is uploaded for library_check(#{self.id})"
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.no_check_data')
      return false
    else
      logger.info "There are #{data_files.length} file(s) for library_check(#{self.id})"
      data_files.each do |f|
        in_file = "#{dir_base}/data_uploads/#{f.id}/original/#{f.file_name}"
        if File.exist?(in_file) then
          logger.info "#{f.file_name} is found"
          files_exists = true
        end
      end
    end
    unless files_exists then
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.no_check_data_exist')
      return false
    end

    #3) shelf definition data
    shelves = LibcheckShelf.find(:all)
    shelves = [] if shelves.nil?
    logger.info "shelves count: #{shelves.length}" unless shelves.nil?

    unless shelves.length > 0
      self.error_msg = I18n.t('activerecord.errors.messages.library_check.no_shelf_definition_data')
      return false
    end
    return true
  rescue => exc
    logger.error exc
    self.error_msg = exc.to_s
    return false
  end
  # end_of_ready_status_check

  # is the checkout type is NDC check target ?
  private
  def check_ndc_type?(checkout_type_name)
    raise "parameter error: checkout_type is nil" if checkout_type_name.nil?

    ndc_check_types = configatron.libcheck_ndc_check
    ndc_check_types = [] if ndc_check_types.nil?

    return ndc_check_types.include?(checkout_type_name)
  end
  # end_of_check_ndc_type

  #------------------------------------------------------------------------
  # for parse NDC

  # return true if num_str only consists of "number"
  private
  def is_number?(num_str)
    return false if num_str.nil?
    return num_str =~ /^[0-9]+$/
  end

  # strip parenthesis and return string which assumed that it is NDC
  private
  def strip_parenthesis(str)
    return str if str.nil?

    ret = str
    if ret =~ /#{PARENTHESIS_PATTERN_1}/
      if is_number?($1) && !is_number?($2)
        ret = $1
      else
        ret = $2
      end
    elsif ret =~ /#{PARENTHESIS_PATTERN_2}/
      if is_number?($1) || !is_number?($2)
        ret = $1
      else is_number?($2)
        ret = $2
      end
    end

    return ret
  end

  private
  def ndc_pad_zero(val)
    return val if val.nil?
    return val + "00" if val.length < 2
    return val + "0" if val.length < 3 
    return val
  end

  # parse NDC
  private
  def fix_ndc(ndc_str)
    ndc_str = ndc_str.strip unless ndc_str.nil?
    ret = {:type => 0, :ndc => nil, :ndc_1 => nil, :ndc_2 => nil, :ndc_3 => nil}
    ret[:ndc] = ndc_str

    return ret if ndc_str.nil? || ndc_str.length < 1

    ndc = strip_parenthesis(ndc_str)
    return ret if ndc.nil?
    ndc = ndc.strip

    x = nil
    y = nil
    z = nil
    if ndc =~ /^(.+)\.(.*)\.(.*)/
      x = $1
      y = $2
      z = $3
      #p "A: => " + x + " - " + y + " - " + z
      if is_number?(x) && is_number?(y) && is_number?(z) && x.length < 4 && y.length < 4 && z.length < 4
        ret[:type] = NDC_TYPE_A
        ret[:ndc] = ndc
        ret[:ndc_1] = ndc_pad_zero(x)
        ret[:ndc_2] = ndc_pad_zero(y)
        ret[:ndc_3] = ndc_pad_zero(z)
      else
        ret[:type] = NDC_TYPE_D
        ret[:ndc] = ndc
      end
    elsif ndc =~ /^(.+)\.(.*)/
      x = $1
      y = $2
      #p "B: => " + x + " - " + y
      if is_number?(x) && is_number?(y) && x.length < 4 && y.length < 4
        ret[:type] = NDC_TYPE_A
        ret[:ndc] = ndc
        ret[:ndc_1] = ndc_pad_zero(x)
        ret[:ndc_2] = ndc_pad_zero(y)
      else
        ret[:type] = NDC_TYPE_D
        ret[:ndc] = ndc
      end
    elsif ndc =~/^R(\d+)$/
      #p "D: => " + ndc
      if $1.length == 4
        ret[:type] = NDC_TYPE_B
      else
        ret[:type] = NDC_TYPE_D
      end
      ret[:ndc] = ndc
    elsif ndc =~ /^[A|B|C|D|E|F|G](\d+)/
      #p "E: => " + ndc
      if $1.length == 3
        ret[:type] = NDC_TYPE_C
      else
        ret[:type] = NDC_TYPE_D
      end
      ret[:ndc] = ndc
    else
      #p "C: => " + ndc
      if is_number?(ndc) && ndc.length < 4
        ret[:type] = NDC_TYPE_A
        ret[:ndc] = ndc
        ret[:ndc_1] = ndc_pad_zero(ndc)
      else
        ret[:type] = NDC_TYPE_D
        ret[:ndc] = ndc
      end
    end
    return ret
  end

#------------------------------------------------------------------------
# following: first version logic

  private 
  def check_confusion_v1
    logger.debug "check confusion"
    ndc_ranges = Hash.new
    type2_ranges = Hash.new

    # create range list
    books = LibcheckTmpItem.find(:all, :select => 'id,ndc,class_type2,shelf_id', :order => 'id')
    shelves = LibcheckShelf.find(:all,:select => 'id,shelf_grp_id',:order => 'id')
    shelves.group_by{|s| s.shelf_grp_id}.each_value{|gp|
      books_per_grp = books.select{|item|
        item.shelf_id.to_i >= gp.first.id.to_i && item.shelf_id.to_i <= gp.last.id.to_i
      }
      unless books_per_grp.blank?
        range_data = get_range(books_per_grp)
        ndc_ranges[gp.first.shelf_grp_id.intern] = range_data[:ndc]
        type2_ranges[gp.first.shelf_grp_id.intern] = range_data[:type2]
      end
    }
=begin
    print ("ndc\n")
    for r in ndc_ranges
      p r
    end
    print ("type2\n")
    for r in type2_ranges
      p r
    end
=end
    
    # check confusion item
    confusion_list = []
    books.each do |book|
      id = book.shelf_id
      target = get_fix_ndc(book.ndc)
      if target.blank?
        target = get_fix_type2(book.class_type2)
        range = type2_ranges[LibcheckShelf.find(id).shelf_grp_id.intern]
      else
        range = ndc_ranges[LibcheckShelf.find(id).shelf_grp_id.intern]
      end
      if (range.first.to_i > target.to_i || range.last.to_i < target.to_i) then
        confusion_list << book.id
      end
    end

    for item in confusion_list
      p item
    end   

    # update confusion flg
    logger.info "Confusion found" 
    logger.info confusion_list
    confusion_list.each do |id|
      rec = LibcheckTmpItem.find(id)
      rec.confusion_flg = "1"
      rec.save
    end
  end
  # end_of_check_confusion

  private
  def get_range(books)
    _books = books
    ret = {:ndc => [nil,nil],:type2 => [nil,nil]}

    for book in _books
      book.ndc = get_fix_ndc(book.ndc)
      book.class_type2 = get_fix_type2(book.class_type2)
    end

    ndc_books = _books.select{|book|
      !book.ndc.blank?
    }
    unless ndc_books.blank? || (ndc_books.size <= 1)
      ret[:ndc] = [ndc_books.first.ndc, ndc_books.last.ndc]
    end

    type2_books = _books.select{|book| book.ndc.blank?}.select{|book| 
      !book.class_type2.blank?
    }
    unless type2_books.blank? || (type2_books.size <= 1)
      ret[:type2] = [type2_books.first.class_type2, type2_books.last.class_type2]
    end
    return ret
  end

  private
  def get_fix_ndc(code)
    return nil if code.blank?
    _code = code.sub(/\..*$/,"")
    if _code =~ /^(\d|\d\d|\d\d\d)$/
      return _code
    else
      return nil
    end
  end
  private
  def get_fix_type2(code)
    return nil if code.blank?
    if code =~ /^\d+$/
      return code
    else
      return nil
    end
  end


end
