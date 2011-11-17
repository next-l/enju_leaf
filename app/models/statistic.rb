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
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
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

  def self.calc_monthly_data(month)
    p "start to calculate monthly data: #{month}"
    # monthly checkout users 1220
    datas = Statistic.select(:value).where(:data_type=> '3220', :yyyymm => month, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 1220
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '3220', :yyyymm => month, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 1220
      statistic.value = value
      statistic.save! if statistic.value > 0
    end 

    # avarage of checkout users per day 1223 
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
    datas = Statistic.select(:value).where(:data_type=> '3330', :yyyymm => month, :library_id => 0)
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
      datas = Statistic.select(:value).where(:data_type=> '3330', :yyyymm => month, :library_id => library.id)
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
    datas = Statistic.select(:value).where(:data_type=> '3430', :yyyymm => month, :library_id => 0)
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
      datas = Statistic.select(:value).where(:data_type=> '3430', :yyyymm => month, :library_id => library.id)
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

    # daily checkout users 2220
    datas = Statistic.select(:value).where(:data_type=> '3220', :yyyymmdd => date, :library_id => 0)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 2220
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '3220', :yyyymmdd => date, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 2220
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
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

  def self.calc_sum(date = nil, monthly = false)
    if monthly # monthly calculate data per month
      unless date.length == 6
        p "input YYYYMM" 
        return false
      end
      date_timestamp =  Time.zone.parse("#{date}01")
      calc_state(Time.new('1970-01-01'), date_timestamp.end_of_month, 1)
      calc_monthly_data(date)
    else # daily calculate data per hour
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
    record = Statistic.where(:data_type => self.data_type, :yyyymmdd => self.yyyymmdd, :yyyymm => self.yyyymm, :library_id => self.library_id, :hour => self.hour).first
    record.destroy if record
  end
end

# data type list
# monthly items: 1110
# monthly users: 1120 / 1121 (available users) / 1122 (locked users)
# monthly checkout users: 1220
# avarage of checkout users per day: 1223 
# monthly reserves: 1330
# monthly questions: 1430
# daily checkout users: 2220
# daily reserves: 2330
# daily questions: 2430
# hourly checkout users: 3220
# hourly reserves: 3330
# hourly questions: 3430
