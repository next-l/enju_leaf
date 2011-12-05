class Statistic < ActiveRecord::Base
  belongs_to :library
  belongs_to :checkout_type
  belongs_to :shelf
  validates_uniqueness_of :data_type, :scope => [:yyyymm, :yyyymmdd, :library_id, :hour, :checkout_type_id, :shelf_id, :ndc, :call_number, :age, :option]
  @libraries = Library.all
  @checkout_types = CheckoutType.all
  @shelves = Shelf.all
  @user_groups = UserGroup.all
  @adult_ids = User.adults.inject([]){|ids, user| ids << user.id}
  @student_ids = User.students.inject([]){|ids, user| ids << user.id}
  @children_ids = User.children.inject([]){|ids, user| ids << user.id}
  before_validation :check_record
  scope :no_condition, where(:checkout_type_id => nil, :shelf_id => nil, :ndc => nil, :call_number => nil, :age => nil, :option => nil)

  def self.calc_state(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics #{start_at} - #{end_at}"

      calc_items(start_at, end_at, term_id)

      # users 120
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 120.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 121 available
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 121.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where locked_at IS NULL AND created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 122 locked
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 122.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where locked_at IS NOT NULL AND created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 124: adults / 125: students / 126: children
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 124.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @adult_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 125.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @student_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 126.to_s
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @children_ids, start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        # users 120
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 120.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 121 available
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 121.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 122 locked
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 122.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NOT NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 124: adults / 125: students / 126: children
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 124.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @adult_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 125.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @student_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 126.to_s
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @children_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
 
    end
    rescue Exception => e
      p "Failed to calculate statistics: #{e}"
      logger.error "Failed to calculate statistics: #{e}"
  end

  def self.calc_items(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of items  #{start_at} - #{end_at}"
      @call_numbers = call_numbers

      # items 11
      data_type = term_id.to_s + 11.to_s
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.value = Item.count_by_sql(["select count(*) from items where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # items each checkout types
      @checkout_types.each do |checkout_type|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.checkout_type = checkout_type
        statistic.value = Item.count_by_sql(["select count(*) from items where checkout_type_id = ? AND created_at >= ? AND created_at  < ?", checkout_type.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # items each call_numbers
      @call_numbers.each do |num|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.call_number = num
        num_reg = "/\|#{num}\|/"
        statistic.value = Item.count_by_sql(["select count(*) from items where call_number ~ ? AND created_at >= ? AND created_at  < ?", num_reg, start_at, end_at])
        statistic.save! if statistic.value > 0        
      end

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.library = library
        statistic.value = statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND libraries.id = ? AND items.created_at >= ? AND items.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # items each checkout types
        @checkout_types.each do |checkout_type|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.checkout_type = checkout_type
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND libraries.id = ? AND items.checkout_type_id = ? AND items.created_at >= ? AND items.created_at < ?", library.id, checkout_type.id, start_at, end_at])
          statistic.save! if statistic.value > 0
        end
        # items each shelves
        @shelves.each do |shelf|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.shelf = shelf
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND libraries.id = ? AND shelves.id = ? AND items.created_at >= ? AND items.created_at < ?", library.id, shelf.id, start_at, end_at])
          statistic.save! if statistic.value > 0
          # items each call_numbers
          @call_numbers.each do |num|
            statistic = Statistic.new
            set_date(statistic, end_at, term_id)
            statistic.data_type = data_type
            statistic.library = library
            statistic.shelf = shelf
            statistic.call_number = num
            num_reg = "/\|#{num}\|/"
            statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND libraries.id = ? AND shelves.id = ? AND items.call_number ~ ? AND items.created_at >= ? AND items.created_at < ?", library.id, shelf.id, num_reg, start_at, end_at])
            statistic.save! if statistic.value > 0
          end
        end
      end
    end
    rescue Exception => e
      p "Failed to calculate items: #{e}"
      logger.error "Failed to calculate items: #{e}"
  end


  def self.calc_checkouts(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of checkouts  #{start_at} - #{end_at}"
   
      # checkout items 210
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 210.to_s
      statistic.value = Checkout.count_by_sql(["select count(*) from checkouts where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for all 217 (ndc starts a number)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 217.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND manifestations.ndc ~ '^[0-9]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for kids 218 (ndc starts K/E/C)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 218.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND manifestations.ndc ~ '^[KEC]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for else 219 (no ndc or ndc starts other alfabet)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 219.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
    
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 210.to_s
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(*) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # NDC for all 217 (ndc starts a number)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 217.to_s
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[0-9]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # NDC for kids 218 (ndc starts K/E/C)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 218.to_s
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[KEC]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # NDC for else 219 (no ndc or ndc starts other alfabet)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 219.to_s
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # checkout users 220
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 220.to_s
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # checkout users 224: adults / 225: students / 226: children
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 224.to_s
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @adult_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 225.to_s
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @student_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 226.to_s
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @children_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
 
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 220.to_s
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # checkout users 224: adults / 225: students / 226: children
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 224.to_s
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @adult_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 225.to_s
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @student_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 226.to_s
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @children_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate checkouts statistics: #{e}"
      logger.error "Failed to calculate checkouts statistics: #{e}"
  end

  def self.calc_reserves(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of reserves  #{start_at} - #{end_at}"

      # reserves 330
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 330.to_s
      statistic.value = Reserve.count_by_sql(["select count(*) from reserves where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 330.to_s
        statistic.library_id = library.id
        statistic.value = Reserve.count_by_sql(["select count(*) from reserves, libraries where libraries.id = reserves.receipt_library_id AND libraries.id = ? AND reserves.created_at >= ? AND reserves.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate reserves statistics: #{e}"
      logger.error "Failed to calculate reserves statistics: #{e}"
  end
  
  def self.calc_questions(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of questions  #{start_at} - #{end_at}"

     # questions 430
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 430.to_s
      statistic.value = Question.count_by_sql(["select count(*) from questions where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 430.to_s
        statistic.library_id = library.id
        statistic.value = Question.count_by_sql(["select count(*) from questions, users, libraries where libraries.id = users.library_id AND users.id = questions.user_id AND libraries.id = ? AND questions.created_at >= ? AND questions.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    
    end
    rescue Exception => e
      p "Failed to calculate questions statistics: #{e}"
      logger.error "Failed to calculate questions statistics: #{e}"
  end

  def self.set_date(statistic, date, term_id = nil)
    statistic.yyyymmdd = date.strftime("%Y%m%d") unless term_id == 1
    statistic.yyyymm = date.strftime("%Y%m") 
    statistic.dd = date.strftime("%d") unless term_id == 1
    statistic.day = date.strftime("%w") unless term_id == 1 # number [0,6] with 0 representing Sunday
    statistic.hour = date.strftime("%H") if term_id == 3
  end

  def self.calc_monthly_data(month)
    p "start to calculate monthly data: #{month}"

    # montyly open days 1130
    y = month[0,4].to_i
    m = month[4,2].to_i
    @libraries.each do |library|
      c = 0
      (1..(Date.new(y, m, -1).day)).each {|d| c += 1 if Event.closing_days.where("start_at <= ? AND ? <= end_at AND library_id = ?", Time.local(y, m, d, 0, 0, 0), Time.local(y, m, d, 0, 0, 0), library.id).count == 0}
      statistic = Statistic.new
      statistic.data_type = 1130
      statistic.library_id = library.id
      statistic.yyyymm = month
      statistic.value = c
      statistic.save!
    end

    # monthly checkout items 1210, 1217-1219
    [0,7,8,9].each do |i|
      data_type = 21.to_s + i.to_s   
      datas = Statistic.select(:value).where(:data_type=> "2#{data_type}", :yyyymm => month, :library_id => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = "1#{data_type}"
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "2#{data_type}", :yyyymm => month, :library_id => library.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        statistic.yyyymm = month
        statistic.data_type = "1#{data_type}"
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end 
    end

    # avarage of checkout items each day 1213 
    date = Date.new(month[0, 4].to_i, month[4, 2].to_i) 
    days = date.end_of_month - date.beginning_of_month + 1
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 1213
    monthly_data = Statistic.select(:value).where(:data_type=> '1210', :yyyymm => month, :library_id => 0).first
    statistic.value = monthly_data.value / days rescue 0
    statistic.save! 

    @libraries.each do |library|
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 1213
      statistic.library_id = library.id
      monthly_data = Statistic.select(:value).where(:data_type=> '1210', :yyyymm => month, :library_id => library.id).first
      statistic.value = monthly_data.value / days rescue 0
      statistic.save! 
    end 

    # monthly checkout users 1220, 1224, 1225, 1226
    [0,4,5,6].each do |type| # [all users, adults, students, children]
      datas = Statistic.select(:value).where(:data_type=> "222#{type}", :yyyymm => month, :library_id => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 122.to_s + type.to_s
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "222#{type}", :yyyymm => month, :library_id => library.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        statistic.yyyymm = month
        statistic.data_type = 122.to_s + type.to_s
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end 

    # avarage of checkout users each day 1223 
    date = Date.new(month[0, 4].to_i, month[4, 2].to_i) 
    days = date.end_of_month - date.beginning_of_month + 1
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 1223
    monthly_data = Statistic.select(:value).where(:data_type=> '1220', :yyyymm => month, :library_id => 0).first
    statistic.value = monthly_data.value / days rescue 0
    statistic.save! 

    @libraries.each do |library|
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 1223
      statistic.library_id = library.id
      monthly_data = Statistic.select(:value).where(:data_type=> '1220', :yyyymm => month, :library_id => library.id).first
      statistic.value = monthly_data.value / days rescue 0
      statistic.save! 
    end 

    # monthly reserves 1330
    datas = Statistic.select(:value).where(:data_type=> '2330', :yyyymm => month, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 1330
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '2330', :yyyymm => month, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 1330
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end

    # monthly questions 1430
    datas = Statistic.select(:value).where(:data_type=> '2430', :yyyymm => month, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 1430
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '2430', :yyyymm => month, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 1430
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_daily_data(date)
    p "start to calculate daily data: #{date}"
    date_timestamp = Time.zone.parse(date)

    # daily checkout items 2210, 2217-2219
    [0,7,8,9].each do |i|
      data_type = 21.to_s + i.to_s
      datas = Statistic.select(:value).where(:data_type=> "3#{data_type}", :yyyymmdd => date, :library_id => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = "2#{data_type}"
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "3#{data_type}", :yyyymmdd => date, :library_id => library.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        set_date(statistic, date_timestamp, 2)
        statistic.data_type = "2#{data_type}"
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end

    # daily checkout users 2220
    [0,4,5,6].each do |type|
      datas = Statistic.select(:value).where(:data_type=> "322#{type}", :yyyymmdd => date, :library_id => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 222.to_s + type.to_s
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "322#{type}", :yyyymmdd => date, :library_id => library.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        set_date(statistic, date_timestamp, 2)
        statistic.data_type = 222.to_s + type.to_s
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end 

    # daily reserves 2330
    datas = Statistic.select(:value).where(:data_type=> '3330', :yyyymmdd => date, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 2330
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '3330', :yyyymmdd => date, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 2330
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end

    # daily questions 2430
    datas = Statistic.select(:value).where(:data_type=> '3430', :yyyymmdd => date, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 2430
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '3430', :yyyymmdd => date, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 2430
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_age_data(start_at, end_at) 
    p "start to calculate age data: #{start_at} - #{end_at}"

    # users 1120 + 0~7
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, end_at, 1)
      statistic.data_type = 1120.to_s + age.to_s
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      # users 1121 available + 0~7
      statistic = Statistic.new
      set_date(statistic, end_at, 1)
      statistic.data_type = 1121.to_s + age.to_s
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      # users 1122 locked + 0~7
      statistic = Statistic.new
      set_date(statistic, end_at, 1)
      statistic.data_type = 1122.to_s + age.to_s
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NOT NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, end_at, 1)
        statistic.data_type = 1120.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
        # users 1121 available + 0~7
        statistic = Statistic.new
        set_date(statistic, end_at, 1)
        statistic.data_type = 1121.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
        # users 1122 locked + 0~7
        statistic = Statistic.new
        set_date(statistic, end_at, 1)
        statistic.data_type = 1122.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NOT NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # checkout users 1220 + 0~7
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1220.to_s + age.to_s
      sql = "select count(distinct checkouts.user_id) from checkouts, users, patrons where checkouts.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
    end
    @libraries.each do |library|
      8.times do |age|
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1220.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(distinct checkouts.user_id) from checkouts, users, patrons, libraries  where checkouts.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "      
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # checkout items 1210 + 0~7 / 1217-1219 + 0~7
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1210.to_s + age.to_s
      sql = "select count(*) from checkouts, users, patrons where checkouts.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for all 217 (ndc starts a number)
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1217.to_s + age.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[0-9]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for kids 218 (ndc starts K/E/C)
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1218.to_s + age.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[KEC]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for else 219 (no ndc or ndc starts other alfabet)
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1219.to_s + age.to_s
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
    end
    @libraries.each do |library|
      8.times do |age|
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1210.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from checkouts, patrons, libraries, users librarian_users, users user_users where checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end  
        statistic.save! if statistic.value > 0
        # NDC for all 217 (ndc starts a number)
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1217.to_s + age.to_s
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[0-9]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
        # NDC for kids 218 (ndc starts K/E/C)
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1218.to_s + age.to_s
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[KEC]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
        # NDC for else 219 (no ndc or ndc starts other alfabet)
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1219.to_s + age.to_s
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, users user_users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # reserves 1330 + 0~7
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1330.to_s + age.to_s
      sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ?"
      unless age == 7
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
    end
    @libraries.each do |library|
      8.times do |age|
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1330.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ?"       
        unless age == 7
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # questions 1430 + 0~7
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, 1)
      statistic.data_type = 1430.to_s + age.to_s
      sql = "select count(*) from questions, users, patrons where questions.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND questions.created_at >= ? AND questions.created_at  <= ?"
      unless age == 7
        statistic.value = Question.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else 
        statistic.value = Question.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
    end
    @libraries.each do |library|
      8.times do |age|
        statistic = Statistic.new
        set_date(statistic, start_at, 1)
        statistic.data_type = 1430.to_s + age.to_s
        statistic.library_id = library.id
        sql = "select count(*) from questions, users, patrons, libraries where questions.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND questions.created_at >= ? AND questions.created_at  <= ?"        
        unless age == 7
          statistic.value = Question.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Question.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end
  end

  def self.calc_sum(date = nil, monthly = false)
    if monthly # monthly calculate data each month
      unless date.length == 6
        p "input YYYYMM" 
        return false
      end
      date_timestamp =  Time.zone.parse("#{date}01")
      calc_state(Time.new('1970-01-01'), date_timestamp.end_of_month, 1)
      calc_age_data(date_timestamp.beginning_of_month, date_timestamp.end_of_month)
      calc_monthly_data(date)
    else # daily calculate data each hour
      if date
        unless date.length == 8
          p "input YYYYMMDD" 
          return false
        end
        date = Time.zone.parse(date)
      else
        date = Time.zone.now.yesterday
      end
      i = 0
      while i < 24 #  0 ~ 24 hour
        calc_checkouts(date.change(:hour => i), date.change(:hour => i + 1), 3)
        calc_reserves(date.change(:hour => i), date.change(:hour => i + 1), 3)
        calc_questions(date.change(:hour => i), date.change(:hour => i + 1), 3)
        i += 1
      end
      calc_daily_data(date.strftime("%Y%m%d"))
    end
    rescue Exception => e
      p "Failed to start calculation: #{e}"
      logger.error "Failed to start calculation: #{e}"
  end

  def check_record
    record = Statistic.where(:data_type => self.data_type, :yyyymmdd => self.yyyymmdd, :yyyymm => self.yyyymm, :library_id => self.library_id, :hour => self.hour, :checkout_type_id => self.checkout_type_id, :shelf_id => self.shelf_id, :ndc => self.ndc, :call_number => self.call_number, :age => self.age, :option => self.option).first
    record.destroy if record
  end
  
  def self.call_numbers
    call_numbers = []
    @libraries.each do |library|
      delimi = library.call_number_delimiter
      delimi = '|' if delimi.nil? || delimi.empty?
      # if you change the rule to scan, modify "# items each call_numbers" above too
      call_numbers << Item.joins(:shelf).where(["shelves.library_id = ?", library.id]).inject([]) {|nums, item| nums << item.call_number.split(delimi)[1]}.compact
    end
    return call_numbers.flatten.uniq!
  end

end
