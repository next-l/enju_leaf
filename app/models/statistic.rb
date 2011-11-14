class Statistic < ActiveRecord::Base
  has_one :library
  validates_uniqueness_of :data_type, :scope => [:yyyymmdd, :library_id, :hour]
  @libraries = Library.all
  @checkout_types = CheckoutType.all
  before_validation :check_record

  def self.calc_state(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics #{start_at} - #{end_at}"

      # items 110
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 110.to_s
      statistic.value = Item.count_by_sql(["select count(*) from items where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 110.to_s
        statistic.library_id = library.id
        statistic.value = statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND libraries.id = ? AND items.created_at >= ? AND items.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end

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

      @libraries.each do |library|
        # users 120
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 120.to_s
        statistic.library_id = library.id
        statistic.value = statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 121 available
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 121.to_s
        statistic.library_id = library.id
        statistic.value = statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 122 locked
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 122.to_s
        statistic.library_id = library.id
        statistic.value = statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NOT NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
 
    end
    rescue Exception => e
      p "Failed to calculate statistics: #{e}"
      logger.error "Failed to calculate statistics: #{e}"
  end

  def self.calc_checkouts(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of checkouts  #{start_at} - #{end_at}"
   
      # checkout users 220
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 220.to_s
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
 
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 220.to_s
        statistic.library_id = library.id
        statistic.value = statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
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
        statistic.value = statistic.value = Reserve.count_by_sql(["select count(*) from reserves, libraries where libraries.id = reserves.receipt_library_id AND libraries.id = ? AND reserves.created_at >= ? AND reserves.created_at < ?", library.id, start_at, end_at])
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
        statistic.value = statistic.value = Question.count_by_sql(["select count(*) from questions, users, libraries where libraries.id = users.library_id AND users.id = questions.user_id AND libraries.id = ? AND questions.created_at >= ? AND questions.created_at < ?", library.id, start_at, end_at])
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

  def self.calc_monthly_data(start_at, end_at)
    # monthly checkout users 1220
 
  end

  def self.calc_sum(date = nil, monthly = false)
    if monthly # monthly calculate data per month
      date =  Time.zone.parse("#{data}01")
      calc_state(Time.new('1970-01-01'), date.end_of_month, 1)
    else # daily calculate data per hour
      if date
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
    end
    rescue Exception => e
      p "Failed to start calculation: #{e}"
      logger.error "Failed to start calculation: #{e}"
  end

  def check_record
    record = Statistic.where(:data_type => self.data_type, :yyyymmdd => self.yyyymmdd, :library_id => self.library_id, :hour => self.hour).first
    record.destroy if record
  end
end

# data type list
# monthly items: 1110
# monthly users: 1120 / 1121 (available users) / 1122 (locked users)
# monthly checkout users: 1220
# monthly checkout items: 1210
# hourly checkout: items 321 
# hourly checkout users: 322
## reserves 303
## questions 403
