# -*- encoding: utf-8 -*-
class Statistic < ActiveRecord::Base
  belongs_to :library
  belongs_to :checkout_type
  belongs_to :shelf
  belongs_to :user_group
  belongs_to :area
  validates_uniqueness_of :data_type, :scope => [:yyyymm, :yyyymmdd, :library_id, :hour, :checkout_type_id, :shelf_id, :ndc, :call_number, :age, :option, :area_id, :user_type, :borrowing_library_id, :user_id]
  @libraries = Library.all
  @checkout_types = CheckoutType.all
  @shelves = Shelf.all
  @user_groups = UserGroup.all
  @areas = Area.all
  @adult_ids = User.adults.inject([]){|ids, user| ids << user.id}
  @student_ids = User.students.inject([]){|ids, user| ids << user.id}
  @junior_ids = User.juniors.inject([]){|ids, user| ids << user.id}
  @elementary_ids = User.elementaries.inject([]){|ids, user| ids << user.id}
  @children_ids = User.children.inject([]){|ids, user| ids << user.id}
  @librarian_ids = User.librarians.inject([]){|ids, user| ids << user.id}
  @corporate_user_ids = User.corporate.inject([]){|ids, user| ids << user.id}
  before_validation :check_record
  scope :no_condition, where(:checkout_type_id => nil, :shelf_id => nil, :ndc => nil, :call_number => nil, :age => nil, :option => 0, :area_id => 0, :user_type => nil, :user_id => nil)

  def self.calc_users(start_at, end_at, term_id)
    Statistic.transaction do
#      p "statistics of users  #{start_at} - #{end_at}"

      data_type = term_id.to_s + 12.to_s
      # users 12 option 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.value = User.count_by_sql(["select count(*) from users where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 12 available option 1
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 1
      statistic.value = User.count_by_sql(["select count(*) from users where locked_at IS NULL AND created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 12 locked option 2
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      statistic.value = User.count_by_sql(["select count(*) from users where locked_at IS NOT NULL AND created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # users 12 provisional option 3
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 3
      statistic.value = User.provisional.where(["created_at >= ? AND created_at  < ?", start_at, end_at]).count
      statistic.save! if statistic.value > 0
      # users 12 each user_type
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 5    
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @adult_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 4
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @student_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 3
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @junior_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 2
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @elementary_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 1
      statistic.value = User.count_by_sql(["select count(*) from users where id IN (?) AND created_at >= ? AND created_at  < ?", @children_ids, start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        # users 12 option 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.option = 0
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 12 available option 1
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.option = 1
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 12 locked option 2
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.option = 2
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND users.locked_at IS NOT NULL AND libraries.id = ? AND users.created_at >= ? AND users.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # users 12 provisional option 3
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.option = 3
        statistic.library_id = library.id
        statistic.value = User.provisional.joins(:library).where(["users.library_id = libraries.id AND libraries.id = ? AND users.created_at >= ? AND users.created_at  < ?", library.id, start_at, end_at]).count
        statistic.save! if statistic.value > 0
        # users 12 each user_type
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 5
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @adult_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 4
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @student_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 3
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @junior_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 2
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @elementary_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 1
        statistic.library_id = library.id
        statistic.value = User.count_by_sql(["select count(*) from users, libraries where users.library_id = libraries.id AND libraries.id = ? AND users.id IN (?) AND users.created_at >= ? AND users.created_at < ?", library.id, @children_ids, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate users: #{e}"
      logger.error "Failed to calculate users: #{e}"
  end

  def self.calc_items(start_at, end_at, term_id)
    Statistic.transaction do
#     p "statistics of items  #{start_at} - #{end_at}"
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
      unless @call_numbers.nil?
        @call_numbers.each do |num|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.call_number = num
          num_reg = "/\|#{num}\|/"
          statistic.value = Item.count_by_sql(["select count(*) from items where call_number ~ ? AND created_at >= ? AND created_at  < ?", num_reg, start_at, end_at])
          statistic.save! if statistic.value > 0        
        end
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
          unless @call_numbers.nil?
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
    end
    rescue Exception => e
      s = "Failed to calculate items: #{e}"
      puts s ; logger.fatal s
      logger.fatal e.backtrace.join("\n")
  end

  def self.calc_inout_items(start_at, end_at, term_id)
    Statistic.transaction do
     p "statistics of inout items #{start_at} - #{end_at}"
      @call_numbers = call_numbers
      circulation_type_remove_id = CirculationStatus.find(:first, :conditions => ["name = ?", 'Removed']).id

      # items 11 accept option: 2
      data_type = term_id.to_s + 11.to_s
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      statistic.value = Item.count_by_sql(["select count(*) from items where item_identifier IS NOT NULL AND circulation_status_id != ? AND created_at >= ? AND created_at  < ?", circulation_type_remove_id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # items 11 remove option: 3
      data_type = term_id.to_s + 11.to_s
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 3
      statistic.value = Item.count_by_sql(["select count(*) from items where circulation_status_id = ? AND removed_at >= ? AND removed_at  < ?", circulation_type_remove_id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # items each checkout types accept option: 2
      @checkout_types.each do |checkout_type|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.checkout_type = checkout_type
        statistic.option = 2
        statistic.value = Item.count_by_sql(["select count(*) from items where item_identifier IS NOT NULL AND circulation_status_id != ? AND checkout_type_id = ? AND created_at >= ? AND created_at  < ?", circulation_type_remove_id, checkout_type.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # items each checkout types remove option: 3
      @checkout_types.each do |checkout_type|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.checkout_type = checkout_type
        statistic.option = 3
        statistic.value = Item.count_by_sql(["select count(*) from items where circulation_status_id = ? AND checkout_type_id = ? AND removed_at >= ? AND removed_at  < ?", circulation_type_remove_id, checkout_type.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # items each call_numbers accept option: 2
      unless @call_numbers.nil?
        @call_numbers.each do |num|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.call_number = num
          statistic.option = 2
          num_reg = "/\|#{num}\|/"
          statistic.value = Item.count_by_sql(["select count(*) from items where item_identifier IS NOT NULL AND circulation_status_id != ? AND call_number ~ ? AND created_at >= ? AND created_at  < ?", circulation_type_remove_id, num_reg, start_at, end_at])
          statistic.save! if statistic.value > 0        
        end
        # items each call_numbers remove option: 3
        @call_numbers.each do |num|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.call_number = num
          statistic.option = 3
          num_reg = "/\|#{num}\|/"
          statistic.value = Item.count_by_sql(["select count(*) from items where circulation_status_id = ? AND call_number ~ ? AND removed_at >= ? AND removed_at  < ?", circulation_type_remove_id, num_reg, start_at, end_at])
          statistic.save! if statistic.value > 0        
        end
      end
      @libraries.each do |library|
        # items each libraries accept option: 2
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.library = library
        statistic.option = 2
        statistic.value = statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.item_identifier IS NOT NULL AND items.circulation_status_id != ? AND libraries.id = ? AND items.created_at >= ? AND items.created_at < ?", circulation_type_remove_id, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # items each libraries remove option: 3
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.library = library
        statistic.option = 3
        statistic.value = statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.circulation_status_id = ? AND libraries.id = ? AND items.removed_at >= ? AND items.removed_at < ?", circulation_type_remove_id, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # items each checkout types accept option: 2
        @checkout_types.each do |checkout_type|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.checkout_type = checkout_type
          statistic.option = 2
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.item_identifier IS NOT NULL AND items.circulation_status_id != ? AND libraries.id = ? AND items.checkout_type_id = ? AND items.created_at >= ? AND items.created_at < ?", circulation_type_remove_id, library.id, checkout_type.id, start_at, end_at])
          statistic.save! if statistic.value > 0
        end
        # items each checkout types remove option: 3
        @checkout_types.each do |checkout_type|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.checkout_type = checkout_type
          statistic.option = 3
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.circulation_status_id = ? AND libraries.id = ? AND items.checkout_type_id = ? AND items.removed_at >= ? AND items.removed_at < ?", circulation_type_remove_id, library.id, checkout_type.id, start_at, end_at])
          statistic.save! if statistic.value > 0
        end
        # items each shelves
        @shelves.each do |shelf|
          # accept option: 2
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.shelf = shelf
          statistic.option = 2
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.item_identifier IS NOT NULL AND items.circulation_status_id != ? AND libraries.id = ? AND shelves.id = ? AND items.created_at >= ? AND items.created_at < ?", circulation_type_remove_id, library.id, shelf.id, start_at, end_at])
          statistic.save! if statistic.value > 0
          # remove option: 3
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.library = library
          statistic.shelf = shelf
          statistic.option = 3
          statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.circulation_status_id = ? AND libraries.id = ? AND shelves.id = ? AND items.removed_at >= ? AND items.removed_at < ?", circulation_type_remove_id, library.id, shelf.id, start_at, end_at])
          statistic.save! if statistic.value > 0
          # items each call_numbers
          unless @call_numbers.nil?
            @call_numbers.each do |num|
              # accept option: 2
              statistic = Statistic.new
              set_date(statistic, end_at, term_id)
              statistic.data_type = data_type
              statistic.library = library
              statistic.shelf = shelf
              statistic.call_number = num
              statistic.option = 2
              num_reg = "/\|#{num}\|/"
              statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.item_identifier IS NOT NULL AND items.circulation_status_id != ? AND libraries.id = ? AND shelves.id = ? AND items.call_number ~ ? AND items.created_at >= ? AND items.created_at < ?", circulation_type_remove_id, library.id, shelf.id, num_reg, start_at, end_at])
              statistic.save! if statistic.value > 0	
              # remove option: 3
              statistic = Statistic.new
              set_date(statistic, end_at, term_id)
              statistic.data_type = data_type
              statistic.library = library
              statistic.shelf = shelf
              statistic.call_number = num
              statistic.option = 3
              num_reg = "/\|#{num}\|/"
              statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.circulation_status_id = ? AND libraries.id = ? AND shelves.id = ? AND items.call_number ~ ? AND items.removed_at >= ? AND items.removed_at < ?", circulation_type_remove_id, library.id, shelf.id, num_reg, start_at, end_at])
              statistic.save! if statistic.value > 0	
            end
          end
        end
      end
    end
    rescue Exception => e
      s = "Failed to calculate inout items: #{e}"
      puts s ; logger.fatal s
      logger.fatal e.backtrace.join("\n")
  end


  def self.calc_missing_items(start_at, end_at, term_id)
    Statistic.transaction do
     p "statistics of missing items  #{start_at} - #{end_at}"
  
      data_type = term_id.to_s + 11.to_s
      missing_state_ids = CirculationStatus.where(['name = ?', 'Circulation Status Undefined']).inject([]){|ids, data| ids << data.id}
      # all libraries
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.option = 1
      statistic.value = Item.count_by_sql(["select count(*) from items where circulation_status_id IN (?) AND created_at >= ? AND created_at  < ?", missing_state_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      # each libraries
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.option = 1
        statistic.library = library
        statistic.value = statistic.value = Item.count_by_sql(["select count(items) from items, shelves, libraries where items.shelf_id = shelves.id AND libraries.id = shelves.library_id AND items.circulation_status_id IN (?) AND libraries.id = ? AND items.created_at >= ? AND items.created_at < ?", missing_state_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end

    end
    rescue Exception => e
      p "Failed to calculate missing items: #{e}"
      logger.error "Failed to calculate missing items: #{e}"
  end

  def self.calc_library_use(start_at, end_at, term_id)
#      p "statistics of library use  #{start_at} - #{end_at}"
    start_at_str = start_at.strftime("%Y%m%d")
    end_at_str = end_at.strftime("%Y%m%d")
    reports = LibraryReport.where(["yyyymmdd >= ? AND yyyymmdd <= ?", start_at_str, end_at_str])
    # copies
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = term_id.to_s + 15.to_s
    statistic.value = reports.inject(0){|sum, data| sum += data.copies if data.copies;sum}
    statistic.save! if statistic.value > 0
    # visiters
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = term_id.to_s + 16.to_s
    statistic.value = reports.inject(0){|sum, data| sum += data.visiters if data.visiters;sum}
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      reports = LibraryReport.where(["yyyymmdd >= ? AND yyyymmdd <= ? AND library_id = ?", start_at_str, end_at_str, library.id])
      # copies
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 15.to_s
      statistic.library = library
      statistic.value = reports.inject(0){|sum, data| sum += data.copies if data.copies;sum}
      statistic.save! if statistic.value > 0
      # visiters
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = term_id.to_s + 16.to_s
      statistic.library = library
      statistic.value = reports.inject(0){|sum, data| sum += data.visiters if data.visiters;sum}
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_loans(start_at, end_at, term_id)
#      p "statistics of inter library loans  #{start_at} - #{end_at}"
    @libraries.each do |library|
      @libraries.each do |borrowing_library|
        # reason: 1 checkout
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 61.to_s
        statistic.library = library
        statistic.borrowing_library_id = borrowing_library.id
        value = InterLibraryLoan.count_by_sql(["select count(*) from inter_library_loans, items where inter_library_loans.item_id = items.id AND inter_library_loans.reason = 1 AND inter_library_loans.from_library_id = ? AND inter_library_loans.to_library_id = ? AND inter_library_loans.shipped_at >= ? AND inter_library_loans.shipped_at <= ?", library.id, borrowing_library.id, start_at, end_at]) 
        statistic.value = value
        statistic.save! if statistic.value > 0
        # reason: 3 checkin
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = term_id.to_s + 62.to_s
        statistic.library = borrowing_library
        statistic.borrowing_library_id = library.id
        value = InterLibraryLoan.joins(:item).count_by_sql(["select count(*) from inter_library_loans, items where inter_library_loans.item_id = items.id AND inter_library_loans.reason = 2 AND inter_library_loans.from_library_id = ? AND inter_library_loans.to_library_id = ? AND inter_library_loans.received_at >= ? AND inter_library_loans.received_at <= ?", borrowing_library.id, library.id, start_at, end_at]) 
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end
  end

  def self.calc_checkouts(start_at, end_at, term_id)
    Statistic.transaction do
#      p "statistics of checkouts  #{start_at} - #{end_at}"

      # checkout items 21
      data_type = term_id.to_s + 21.to_s   
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.value = Checkout.count_by_sql(["select count(*) from checkouts where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # checkout items each user_group
      @user_groups.each do |user_group|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_group = user_group
        statistic.value = Checkout.count_by_sql(["select count(checkouts) from checkouts, users  where checkouts.user_id = users.id AND users.user_group_id = ? AND checkouts.created_at >= ? AND checkouts.created_at  < ?", user_group.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # checkout items each corporate users
      @corporate_user_ids.each do |id|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_id = id
        statistic.value = Checkout.count_by_sql(["select count(checkouts) from checkouts where user_id = ? AND created_at >= ? AND created_at < ? ", id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # NDC for all option: 1 (ndc starts a number)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type 
      statistic.option = 1
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND manifestations.ndc ~ '^[0-9]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for kids option: 2 (ndc starts K/E/C)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND manifestations.ndc ~ '^[KEC]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for else option: 3 (no ndc or ndc starts other alfabet)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 3
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND checkouts.created_at >= ? AND checkouts.created_at < ?"
      statistic.value = Checkout.count_by_sql([ sql, start_at, end_at])
      statistic.save! if statistic.value > 0
    
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(*) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # each user_groups
        @user_groups.each do |user_group|
          statistic = Statistic.new
          set_date(statistic, start_at, term_id)
          statistic.data_type = data_type
          statistic.library_id = library.id
          statistic.user_group = user_group
          statistic.value = Checkout.count_by_sql(["select count(*) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND users.user_group_id = ? AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", user_group.id, library.id, start_at, end_at])
          statistic.save! if statistic.value > 0
        end
        # NDC for all option: 1 (ndc starts a number)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 1
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[0-9]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # NDC for kids option: 2 (ndc starts K/E/C)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 2
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[KEC]' AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # NDC for else option: 3 (no ndc or ndc starts other alfabet)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 3
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND checkouts.created_at >= ? AND checkouts.created_at < ?"
        statistic.value = Checkout.count_by_sql([ sql, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end

      # checkout users 22
      data_type = term_id.to_s + 22.to_s
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # checkout each user_type
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 5
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @adult_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 4
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @student_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 3
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @junior_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 2
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @elementary_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.user_type = 1
      statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts where user_id IN (?) AND created_at >= ? AND created_at  < ?", @children_ids, start_at, end_at])
      statistic.save! if statistic.value > 0
 
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # checkout each user_type
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 5
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @adult_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 4
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @student_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 3
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @junior_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 2
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @elementary_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.user_type = 1
        statistic.library_id = library.id
        statistic.value = Checkout.count_by_sql(["select count(distinct user_id) from checkouts, users, libraries where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND user_id IN (?) AND libraries.id = ? AND checkouts.created_at >= ? AND checkouts.created_at < ?", @children_ids, library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate checkouts statistics: #{e}"
      logger.error "Failed to calculate checkouts statistics: #{e}"
  end

  def self.calc_ndc_checkouts(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of ndc checkouts  #{start_at} - #{end_at}"
      @libraries.each do |library|
        10.times do |i|
          statistic = Statistic.new
          set_date(statistic, start_at, term_id)
          statistic.data_type = term_id.to_s + 21.to_s
          statistic.ndc = i.to_s
          statistic.library_id = library.id
          reg = "^\\D*[#{i}]"
          sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = users.id AND users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ ? AND checkouts.created_at >= ? AND checkouts.created_at < ?"
          statistic.value = Checkout.count_by_sql([ sql, library.id, reg, start_at, end_at])
          statistic.save! if statistic.value > 0
        end
      end
    end
    rescue Exception => e
      p "Failed to calculate ndc checkouts statistics: #{e}"
      logger.error "Failed to calculate ndc  checkouts statistics: #{e}"
  end

  def self.calc_reminders(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of reminders  #{start_at} - #{end_at}"

      # reminder checkouts 
      data_type = term_id.to_s + 21.to_s   
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 5
      statistic.value = Checkout.count_by_sql(["select count(*) from checkouts, reminder_lists where checkouts.id = reminder_lists.checkout_id AND reminder_lists.created_at >= ? AND reminder_lists.created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # reminder checkouts each libraries
      @libraries.each do |library|
        data_type = term_id.to_s + 21.to_s   
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 5
        statistic.library = library
        statistic.value = Checkout.count_by_sql(["select count(*) from checkouts, users, libraries, reminder_lists where checkouts.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkouts.id = reminder_lists.checkout_id AND reminder_lists.created_at >= ? AND reminder_lists.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
      # checkins remindered emiko
      data_type = term_id.to_s + 51.to_s   
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 5
      statistic.value = Checkin.count_by_sql(["select count(*) from checkins, checkouts, reminder_lists where checkins.id = checkouts.checkin_id AND checkouts.id = reminder_lists.checkout_id AND checkins.created_at >= ? AND checkins.created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.option = 5
        statistic.value = Checkin.count_by_sql(["select count(*) from checkins, checkouts, reminder_lists, users, libraries where checkins.id = checkouts.checkin_id AND checkouts.id = reminder_lists.checkout_id AND checkins.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkins.created_at >= ? AND checkins.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
  end

  def self.calc_checkins(start_at, end_at, term_id)
    Statistic.transaction do
#      p "statistics of checkins  #{start_at} - #{end_at}"
      # checkin items 51
      data_type = term_id.to_s + 51.to_s   
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.value = Checkin.count_by_sql(["select count(*) from checkins where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.value = Checkin.count_by_sql(["select count(*) from checkins, users, libraries where checkins.librarian_id = users.id AND users.library_id= libraries.id AND libraries.id = ? AND checkins.created_at >= ? AND checkins.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate checkins statistics: #{e}"
      logger.error "Failed to calculate checkins statistics: #{e}"
  end

  def self.calc_reserves(start_at, end_at, term_id)
    Statistic.transaction do
#      p "statistics of reserves  #{start_at} - #{end_at}"

      # reserves 33
      data_type = term_id.to_s + 33.to_s
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.value = Reserve.count_by_sql(["select count(*) from reserves where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0
      # reserves on counter by Librarian 33 option: 1
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 1
      statistic.value = Reserve.count_by_sql(["select count(*) from reserves where created_at >= ? AND created_at  < ? AND created_by IN (?)", start_at, end_at, @librarian_ids])
      statistic.save! if statistic.value > 0
      # reserves from OPAC by user  33 option: 2
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      statistic.value = Reserve.count_by_sql(["select count(*) from reserves where created_at >= ? AND created_at  < ? AND created_by NOT IN (?)", start_at, end_at, @librarian_ids])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.value = Reserve.count_by_sql(["select count(*) from reserves, libraries where libraries.id = reserves.receipt_library_id AND libraries.id = ? AND reserves.created_at >= ? AND reserves.created_at < ?", library.id, start_at, end_at])
        statistic.save! if statistic.value > 0
        # reserve on counter
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.option = 1
        statistic.value = Reserve.count_by_sql(["select count(*) from reserves, libraries where libraries.id = reserves.receipt_library_id AND libraries.id = ? AND reserves.created_at >= ? AND reserves.created_at < ? AND reserves.created_by IN (?)", library.id, start_at, end_at, @librarian_ids])
        statistic.save! if statistic.value > 0
        # reserve from OPAC
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.library_id = library.id
        statistic.option = 2
        statistic.value = Reserve.count_by_sql(["select count(*) from reserves, libraries where libraries.id = reserves.receipt_library_id AND libraries.id = ? AND reserves.created_at >= ? AND reserves.created_at < ? AND reserves.created_by NOT IN (?)", library.id, start_at, end_at, @librarian_ids])
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate reserves statistics: #{e}"
      logger.error "Failed to calculate reserves statistics: #{e}"
  end
  
  def self.calc_questions(start_at, end_at, term_id)
    Statistic.transaction do
#      p "statistics of questions  #{start_at} - #{end_at}"

     # questions 43
      data_type = term_id.to_s + 43.to_s
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.value = Question.count_by_sql(["select count(*) from questions where created_at >= ? AND created_at  < ?", start_at, end_at])
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
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

  def self.calc_consultations(start_at, end_at, term_id)
    Statistic.transaction do
      p "statistics of consultations  #{start_at} - #{end_at}"
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = term_id.to_s + 14.to_s
      datas = LibraryReport.where(['yyyymmdd >= ? AND yyyymmdd <= ?', start_at.strftime("%Y%m%d"), end_at.strftime("%Y%m%d")])
      value = 0
      datas.each do |data|
        value += data.consultations unless data.consultations.nil?
      end
      statistic.value = value
      statistic.save! if statistic.value > 0
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = term_id.to_s + 14.to_s
        statistic.library_id = library.id
        datas = LibraryReport.where(['yyyymmdd >= ? AND yyyymmdd <= ? AND library_id = ?', start_at.strftime("%Y%m%d"), end_at.strftime("%Y%m%d"), library.id])
        value = 0
        datas.each do |data|
          value += data.consultations unless data.consultations.nil?
        end
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end
    rescue Exception => e
      p "Failed to calculate consultations statistics: #{e}"
      logger.error "Failed to calculate consulatations statistics: #{e}"
  end

  def self.calc_monthly_data(month)
    p "start to calculate monthly data: #{month}"

    # montyly open days 113
    y = month[0,4].to_i
    m = month[4,2].to_i
    @libraries.each do |library|
      c = 0
      (1..(Date.new(y, m, -1).day)).each {|d| c += 1 if Event.closing_days.where("start_at <= ? AND ? <= end_at AND library_id = ?", Time.local(y, m, d, 0, 0, 0), Time.local(y, m, d, 0, 0, 0), library.id).count == 0}
      statistic = Statistic.new
      statistic.data_type = 113
      statistic.library_id = library.id
      statistic.yyyymm = month
      statistic.value = c
      statistic.save!
    end

    # monthly checkout items 121, option 0-3
    4.times do |i|
      data_type = 21
      datas = Statistic.select(:value).where(:data_type=> "2#{data_type}", :yyyymm => month, :library_id => 0, :option => i, :user_group_id => nil)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = "1#{data_type}"
      statistic.option = i
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "2#{data_type}", :yyyymm => month, :library_id => library.id, :option => i, :user_group_id => nil)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        statistic.yyyymm = month
        statistic.data_type = "1#{data_type}"
        statistic.option = i
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end 
    end
    # monthly checkout items each corporate users
    @corporate_user_ids.each do |id|
      datas = Statistic.select(:value).where(:data_type=> 221, :yyyymm => month, :library_id => 0, :user_id => id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 121
      statistic.user_id = id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
    # monthly checkout items each user_group
    @user_groups.each do |user_group|
      datas = Statistic.select(:value).where(:data_type=> 221, :yyyymm => month, :library_id => 0, :user_group_id => user_group.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 121
      statistic.user_group = user_group
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> 221, :yyyymm => month, :library_id => library.id, :user_group_id => user_group.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        statistic.yyyymm = month
        statistic.data_type = 121
        statistic.user_group = user_group
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end 
    end

    # average of checkout items each day 121 option: 4 
    date = Date.new(month[0, 4].to_i, month[4, 2].to_i) 
    days = date.end_of_month - date.beginning_of_month + 1
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 121
    statistic.option = 4
    monthly_data = Statistic.select(:value).where(:data_type=> '121', :yyyymm => month, :library_id => 0).no_condition.first
    statistic.value = monthly_data.value / days rescue 0
    statistic.save! 

    @libraries.each do |library|
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 121
      statistic.option = 4
      statistic.library_id = library.id
      monthly_data = Statistic.select(:value).where(:data_type=> '121', :yyyymm => month, :library_id => library.id).first
      statistic.value = monthly_data.value / days rescue 0
      statistic.save! 
    end 

    # monthly checkout users 122
    datas = Statistic.select(:value).where(:data_type=> "222", :yyyymm => month, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 122
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> "222", :yyyymm => month, :library_id => library.id).no_condition
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 122
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
    # monthly checkout users each user_type
    5.times do |type|
      datas = Statistic.select(:value).where(:data_type=> "222", :yyyymm => month, :library_id => 0, :user_type => type+1)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 122
      statistic.user_type = type + 1
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "222", :yyyymm => month, :library_id => library.id, :user_type => type+1)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        statistic.yyyymm = month
        statistic.data_type = 122
        statistic.user_type = type + 1
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end 

    # avarage of checkout users each day 122 option: 4
    date = Date.new(month[0, 4].to_i, month[4, 2].to_i) 
    days = date.end_of_month - date.beginning_of_month + 1
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 122
    statistic.option = 4
    monthly_data = Statistic.select(:value).where(:data_type=> '122', :yyyymm => month, :library_id => 0).no_condition.first
    statistic.value = monthly_data.value / days rescue 0
    statistic.save! 

    @libraries.each do |library|
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 122
      statistic.option = 4
      statistic.library_id = library.id
      monthly_data = Statistic.select(:value).where(:data_type=> '122', :yyyymm => month, :library_id => library.id).no_condition.first
      statistic.value = monthly_data.value / days rescue 0
      statistic.save! 
    end 

    # monthly checkins 151
    datas = Statistic.select(:value).where(:data_type=> '251', :yyyymm => month, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 151
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '251', :yyyymm => month, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 151
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
    # average of checkin items each day 151 option: 4 
    date = Date.new(month[0, 4].to_i, month[4, 2].to_i) 
    days = date.end_of_month - date.beginning_of_month + 1
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 151
    statistic.option = 4
    monthly_data = Statistic.select(:value).where(:data_type=> '151', :yyyymm => month, :library_id => 0).no_condition.first
    statistic.value = monthly_data.value / days rescue 0
    statistic.save! 

    @libraries.each do |library|
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 151
      statistic.option = 4
      statistic.library_id = library.id
      monthly_data = Statistic.select(:value).where(:data_type=> '151', :yyyymm => month, :library_id => library.id).first
      statistic.value = monthly_data.value / days rescue 0
      statistic.save! 
    end 


    # monthly reserves 133
    datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 133
    statistic.value = value
    statistic.save! if statistic.value > 0
    # on counter option: 1
    datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => 0, :option => 1)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 133
    statistic.option = 1
    statistic.value = value
    statistic.save! if statistic.value > 0
    # from OPAC option: 2
    datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => 0, :option => 2)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 133
    statistic.option = 2
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => library.id, :option => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 133
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
      # on counter
      datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => library.id, :option => 1)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 133
      statistic.library_id = library.id
      statistic.option = 1
      statistic.value = value
      statistic.save! if statistic.value > 0
      # from OPAC
      datas = Statistic.select(:value).where(:data_type=> '233', :yyyymm => month, :library_id => library.id, :option => 2)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 133
      statistic.library_id = library.id
      statistic.option = 2
      statistic.value = value
      statistic.save! if statistic.value > 0
    end

    # monthly questions 143
    datas = Statistic.select(:value).where(:data_type=> '243', :yyyymm => month, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    statistic.yyyymm = month
    statistic.data_type = 143
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '243', :yyyymm => month, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      statistic.yyyymm = month
      statistic.data_type = 143
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_daily_data(date)
    p "start to calculate daily data: #{date}"
    date_timestamp = Time.zone.parse(date)

    # daily checkout items 221, option: 0-3
    4.times do |i|
      data_type = 21
      datas = Statistic.select(:value).where(:data_type=> "3#{data_type}", :yyyymmdd => date, :library_id => 0, :option => i, :user_group_id => nil)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = "2#{data_type}"
      statistic.option = i
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "3#{data_type}", :yyyymmdd => date, :library_id => library.id, :option => i, :user_group_id => nil)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        set_date(statistic, date_timestamp, 2)
        statistic.data_type = "2#{data_type}"
        statistic.option = i
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end
    # daily checkout items each corporate users
    @corporate_user_ids.each do |id|
      datas = Statistic.select(:value).where(:data_type=> 321, :yyyymmdd => date, :library_id => 0, :user_id => id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 221
      statistic.user_id = id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
    # daily checkout items each user_group
    @user_groups.each do |user_group|
      datas = Statistic.select(:value).where(:data_type=> 321, :yyyymmdd => date, :library_id => 0, :user_group_id => user_group.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 221
      statistic.user_group = user_group
      statistic.value = value
      statistic.save! if statistic.value > 0
      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> 321, :yyyymmdd => date, :library_id => library.id, :user_group_id => user_group.id)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        set_date(statistic, date_timestamp, 2)
        statistic.data_type = 221
        statistic.user_group = user_group
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end
    # each ndc for report
    calc_ndc_checkouts(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 2)
   
 
    # daily checkout users 222
    datas = Statistic.select(:value).where(:data_type=> "322", :yyyymmdd => date, :library_id => 0, :age => nil).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 222
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> "322", :yyyymmdd => date, :library_id => library.id, :age => nil).no_condition
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 222
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
    # daily checkout users each user_type
    5.times do |type|
      datas = Statistic.select(:value).where(:data_type=> "322", :yyyymmdd => date, :library_id => 0, :user_type => type+1, :age => nil)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 222
      statistic.user_type = type + 1
      statistic.value = value
      statistic.save! if statistic.value > 0

      @libraries.each do |library|
        datas = Statistic.select(:value).where(:data_type=> "322", :yyyymmdd => date, :library_id => library.id, :user_type => type+1, :age => nil)
        value = 0
        datas.each do |data|
          value = value + data.value
        end
        statistic = Statistic.new
        set_date(statistic, date_timestamp, 2)
        statistic.data_type = 222
        statistic.user_type = type + 1
        statistic.library_id = library.id
        statistic.value = value
        statistic.save! if statistic.value > 0
      end
    end 
    # daily checkin 251
    datas = Statistic.select(:value).where(:data_type=> '351', :yyyymmdd => date, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 251
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '351', :yyyymmdd => date, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 251
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end

    # daily reserves 233
    datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 233
    statistic.value = value
    statistic.save! if statistic.value > 0
    # on counter option: 1
    datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => 0, :option => 1)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 233
    statistic.option = 1
    statistic.value = value
    statistic.save! if statistic.value > 0
    # from OPAC option: 2
    datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => 0, :option => 2)
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 233
    statistic.option = 2
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => library.id, :option => 0)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 233
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
      # on counter option: 1
      datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => library.id, :option => 1)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 233
      statistic.library_id = library.id
      statistic.option = 1
      statistic.value = value
      statistic.save! if statistic.value > 0
      # from OPAN option: 2
      datas = Statistic.select(:value).where(:data_type=> '333', :yyyymmdd => date, :library_id => library.id, :option => 2)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 233
      statistic.library_id = library.id
      statistic.option = 2
      statistic.value = value
      statistic.save! if statistic.value > 0
    end

    # daily questions 243
    datas = Statistic.select(:value).where(:data_type=> '343', :yyyymmdd => date, :library_id => 0).no_condition
    value = 0
    datas.each do |data|
      value = value + data.value
    end
    statistic = Statistic.new
    set_date(statistic, date_timestamp, 2)
    statistic.data_type = 243
    statistic.value = value
    statistic.save! if statistic.value > 0

    @libraries.each do |library|
      datas = Statistic.select(:value).where(:data_type=> '343', :yyyymmdd => date, :library_id => library.id)
      value = 0
      datas.each do |data|
        value = value + data.value
      end
      statistic = Statistic.new
      set_date(statistic, date_timestamp, 2)
      statistic.data_type = 243
      statistic.library_id = library.id
      statistic.value = value
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_age_data(start_at, end_at, term_id) 
    p "start to calculate age data: #{start_at} - #{end_at}"

    # users 12 age 0~7
    data_type = term_id.to_s + 12.to_s
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      # users 12 available age 0~7
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      # users 12 locked + 0~7
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NOT NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      # provional users 12 option: 3
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      statistic.option = 3
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.provisional.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.provisional.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
      
      @libraries.each do |library|
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
        # users 12 available + 0~7
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
        # users 12 locked + 0~7
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NOT NULL AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
        # provisional users 12 option: 3
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.option = 3
        statistic.library_id = library.id
        sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
        unless age == 7
          statistic.value = User.provisional.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
        else
          statistic.value = User.provisional.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # users without date_of_birth
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from users, patrons where users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
    statistic.value = User.count_by_sql([sql, end_at])
    statistic.save! if statistic.value > 0
    # users 12 available
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NULL AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
    statistic.value = User.count_by_sql([sql, end_at])
    statistic.save! if statistic.value > 0
    # users 12 locked
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from users, patrons where users.id = patrons.user_id AND users.locked_at IS NOT NULL AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
    statistic.value = User.count_by_sql([sql, end_at])
    statistic.save! if statistic.value > 0
    # provisional users 12 option: 3
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    statistic.option = 3
    sql = "select count(*) from users, patrons where users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
    statistic.value = User.provisional.count_by_sql([sql, end_at])
    statistic.save! if statistic.value > 0
    @libraries.each do |library|
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
      statistic.value = User.count_by_sql([sql, library.id, end_at])
      statistic.save! if statistic.value > 0
      # users 12 available
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NULL AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
      statistic.value = User.count_by_sql([sql, library.id, end_at])
      statistic.save! if statistic.value > 0
      # users 12 locked
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND users.locked_at IS NOT NULL AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
      statistic.value = User.count_by_sql([sql, library.id, end_at])
      statistic.save! if statistic.value > 0
      # provisional users 12 option: 3
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      statistic.option = 3
      sql = "select count(*) from users, patrons, libraries where users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
      statistic.value = User.provisional.count_by_sql([sql, library.id, end_at])
      statistic.save! if statistic.value > 0
    end

##############################################
    # areas users 62 + 0~7
    data_type = term_id.to_s + 62.to_s
    # all areas
=begin
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      statistic.area_id = 0
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      sql = "select count(*) from users, patrons where users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND users.created_at <= ?"
      unless age == 7
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, end_at])
      else
        statistic.value = User.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, end_at])
      end
      statistic.save! if statistic.value > 0
    end
    # users without date_of_birth
    statistic = Statistic.new
    set_date(statistic, end_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    statistic.area_id = 0
    sql = "select count(*) from users, patrons where users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND users.created_at <= ?"
    statistic.value = User.count_by_sql([sql, end_at])
    statistic.save! if statistic.value > 0
=end
    # each area
    @known_users = []
    @areas.each do |area|
      include_areas = area.address.split(/\s*,\s*/)
      like_address = ""
      include_areas.each_with_index do |include_area, i|
        include_area.gsub!(/^[　\s]*(.*?)[　\s]*$/, '\1')
        8.times do |age|
          statistic = Statistic.new
          set_date(statistic, end_at, term_id)
          statistic.data_type = data_type
          statistic.age = age
          statistic.area_id = area.id
          statistic.option = i * 10  + 1
          start_date = Time.now
          end_date = Time.now
          end_date = end_date.years_ago((age.to_s + 0.to_s).to_i)
          unless age == 7
            start_date = start_date.years_ago((age.to_s + 9.to_s).to_i)
          else
            start_date = start_date.years_ago(200)
          end
          query = "date_of_birth_d: [#{start_date.beginning_of_day.utc.iso8601} TO #{end_date.end_of_day.utc.iso8601}]"
          query = "#{query} address_text: #{include_area}"
          users = User.search do
            fulltext query
            with(:created_at).less_than end_at
          end.results
          users.each do |user|
            @known_users << user
          end
          statistic.value = users.size
          statistic.save! if statistic.value > 0
        end
        # users without date_of_birth
        statistic = Statistic.new
        set_date(statistic, end_at, term_id)
        statistic.data_type = data_type
        statistic.age = 10
        statistic.area_id = area.id
        statistic.option = i * 10
        query = "-date_of_birth_d: [* TO *]"
        query = "#{query} address_1_text: #{include_area}"
        users = User.search do
          fulltext query
          with(:created_at).less_than end_at
        end.results
        users.each do |user|
          @known_users << user
        end
        statistic.value = users.size
        statistic.save! if statistic.value > 0
      end
    end
    #set unknown_area_users
    @users = User.where("created_at < ? ", end_at) 
    ages = Array.new(9, 0)
    @users.each do |user|
      if @known_users.index(user) == nil
        if user.patron.date_of_birth
          8.times do |age|
            #start_date = Time.now
            #end_date = Time.now
            end_date = Time.now.years_ago((age.to_s + 0.to_s).to_i)
            start_date = Time.now.years_ago((age.to_s + 9.to_s).to_i) unless age == 7
            start_date = Time.now.years_ago(200) if age == 7
            if user.patron.date_of_birth = start_date.beginning_of_day.utc.iso8601..end_date.end_of_day.utc.iso8601
              ages[age] = ages[age] + 1
              break 
            end
          end
        else
          ages[8] = ages[8] + 1
        end
      end
    end
    ages.each_with_index do |age, i|
      statistic = Statistic.new
      set_date(statistic, end_at, term_id)
      statistic.data_type = data_type
      statistic.area_id = 0
      statistic.age = i unless i == 8
      statistic.age = 10 if i == 8
      statistic.value = age
      statistic.save! if age > 0
    end

    # checkout users 22 + 0~7
    data_type = term_id.to_s + 22.to_s
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
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
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
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

    # checkout users 22 without date_of_birth
    data_type = term_id.to_s + 22.to_s
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(distinct checkouts.user_id) from checkouts, users, patrons where checkouts.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
    statistic.value = Checkout.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    @libraries.each do |library|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(distinct checkouts.user_id) from checkouts, users, patrons, libraries  where checkouts.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ? "      
      statistic.value = Checkout.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
    end

    # checkout items 21 age: 0~7 / option: 0~4
    data_type = term_id.to_s + 21.to_s
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      sql = "select count(*) from checkouts, users, patrons where checkouts.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for all option: 1 (ndc starts a number)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      statistic.option = 1
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[0-9]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for kids option: 2 (ndc starts K/E/C)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      statistic.option = 2
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[KEC]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      unless age == 7
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Checkout.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # NDC for else option: 3 (no ndc or ndc starts other alfabet)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      statistic.option = 3
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
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from checkouts, patrons, libraries, users librarian_users, users user_users where checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end  
        statistic.save! if statistic.value > 0
        # NDC for all option: 1 (ndc starts a number)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.option = 1
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[0-9]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
        # NDC for kids option: 2 (ndc starts K/E/C)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.option = 2
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[KEC]' AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
        # NDC for else option: 3 (no ndc or ndc starts other alfabet)
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.option = 3
        statistic.library_id = library.id
        sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, users user_users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
        unless age == 7
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Checkout.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # checkout items 21 withou date_of_birth
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from checkouts, users, patrons where checkouts.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
    statistic.value = Checkout.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    # NDC for all option: 1 (ndc starts a number)
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    statistic.option = 1
    sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[0-9]' AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
    statistic.value = Checkout.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    # NDC for kids option: 2 (ndc starts K/E/C)
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    statistic.option = 2
    sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND manifestations.ndc ~ '^[KEC]' AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
    statistic.value = Checkout.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    # NDC for else option: 3 (no ndc or ndc starts other alfabet)
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    statistic.option = 3
    sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users, patrons where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.user_id = users.id AND users.id = patrons.user_id AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
    statistic.value = Checkout.count_by_sql([sql, start_at, end_at])
    @libraries.each do |library|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from checkouts, patrons, libraries, users librarian_users, users user_users where checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ? "
      statistic.value = Checkout.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for all option: 1 (ndc starts a number)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.option = 1
      statistic.library_id = library.id
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[0-9]' AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      statistic.value = Checkout.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for kids option: 2 (ndc starts K/E/C)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.option = 2
      statistic.library_id = library.id
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, libraries, users user_users where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND manifestations.ndc ~ '^[KEC]' AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      statistic.value = Checkout.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # NDC for else option: 3 (no ndc or ndc starts other alfabet)
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.option = 3
      statistic.library_id = library.id
      sql = "select count(checkouts) from checkouts, items, exemplifies, manifestations, users librarian_users, patrons, users user_users, libraries where checkouts.item_id = items.id AND exemplifies.item_id = items.id AND exemplifies.manifestation_id = manifestations.id AND checkouts.librarian_id = librarian_users.id AND checkouts.user_id = user_users.id AND user_users.id = patrons.user_id AND librarian_users.library_id = libraries.id AND libraries.id = ? AND (manifestations.ndc ~ '^[^KEC0-9]' OR manifestations.ndc IS NULL) AND patrons.date_of_birth IS NULL AND checkouts.created_at >= ? AND checkouts.created_at <= ?"
      statistic.value = Checkout.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
    end

    # reserves 33 age: 0~7
    data_type = term_id.to_s + 33.to_s
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
      sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ?"
      unless age == 7
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
      else
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
      end
      statistic.save! if statistic.value > 0
      # on counter option: 1
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 1
      statistic.age = age
      sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by IN (?)"
      unless age == 7
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at, @librarian_ids])
      else
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at, @librarian_ids])
      end
      statistic.save! if statistic.value > 0
      # from OPAC
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      statistic.age = age
      sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by NOT IN (?)"
      unless age == 7
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at, @librarian_ids])
      else
        statistic.value = Reserve.count_by_sql([sql, (age.to_s + 0.to_s).to_i, 200, start_at, end_at, @librarian_ids])
      end
      statistic.save! if statistic.value > 0
    end
    @libraries.each do |library|
      8.times do |age|
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ?"       
        unless age == 7
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at])
        else
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at])
        end
        statistic.save! if statistic.value > 0
        # on counter
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 1
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by IN (?)"       
        unless age == 7
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at, @librarian_ids])
        else
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at, @librarian_ids])
        end
        statistic.save! if statistic.value > 0
        # from OPAC
        statistic = Statistic.new
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.option = 2
        statistic.age = age
        statistic.library_id = library.id
        sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND date_part('year', age(patrons.date_of_birth)) >= ? AND date_part('year', age(patrons.date_of_birth)) <= ? AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by NOT IN (?)"       
        unless age == 7
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, (age.to_s + 9.to_s).to_i, start_at, end_at, @librarian_ids])
        else
          statistic.value = Reserve.count_by_sql([sql, library.id, (age.to_s + 0.to_s).to_i, 200, start_at, end_at, @librarian_ids])
        end
        statistic.save! if statistic.value > 0
      end
    end

    # reserves 33 without date_of_birth
    data_type = term_id.to_s + 33.to_s
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ?"
    statistic.value = Reserve.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    # on counter option: 1
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.option = 1
    statistic.age = 10
    sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by IN (?)"
    statistic.value = Reserve.count_by_sql([sql, start_at, end_at, @librarian_ids])
    statistic.save! if statistic.value > 0
    # from OPAC
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.option = 2
    statistic.age = 10
    sql = "select count(*) from reserves, users, patrons where reserves.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by NOT IN (?)"
    statistic.value = Reserve.count_by_sql([sql, start_at, end_at, @librarian_ids])
    statistic.save! if statistic.value > 0
    @libraries.each do |library|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ?"       
      statistic.value = Reserve.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
      # on counter
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 1
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by IN (?)"       
      statistic.value = Reserve.count_by_sql([sql, library.id, start_at, end_at, @librarian_ids])
      statistic.save! if statistic.value > 0
      # from OPAC
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.option = 2
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from reserves, users, patrons, libraries where reserves.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND reserves.created_at >= ? AND reserves.created_at  <= ? AND reserves.created_by NOT IN (?)"       
      statistic.value = Reserve.count_by_sql([sql, library.id, start_at, end_at, @librarian_ids])
      statistic.save! if statistic.value > 0
    end

    # questions 43 age: 0~7
    data_type = term_id.to_s + 43.to_s
    8.times do |age|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = age
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
        set_date(statistic, start_at, term_id)
        statistic.data_type = data_type
        statistic.age = age
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

    # questions 43 without date_of_birth
    data_type = term_id.to_s + 43.to_s
    statistic = Statistic.new
    set_date(statistic, start_at, term_id)
    statistic.data_type = data_type
    statistic.age = 10
    sql = "select count(*) from questions, users, patrons where questions.user_id = users.id AND users.id = patrons.user_id AND patrons.date_of_birth IS NULL AND questions.created_at >= ? AND questions.created_at  <= ?"
    statistic.value = Question.count_by_sql([sql, start_at, end_at])
    statistic.save! if statistic.value > 0
    @libraries.each do |library|
      statistic = Statistic.new
      set_date(statistic, start_at, term_id)
      statistic.data_type = data_type
      statistic.age = 10
      statistic.library_id = library.id
      sql = "select count(*) from questions, users, patrons, libraries where questions.user_id = users.id AND users.id = patrons.user_id AND users.library_id = libraries.id AND libraries.id = ? AND patrons.date_of_birth IS NULL AND questions.created_at >= ? AND questions.created_at  <= ?"        
      statistic.value = Question.count_by_sql([sql, library.id, start_at, end_at])
      statistic.save! if statistic.value > 0
    end
  end

  def self.calc_sum_prev_month
    date = Time.now.prev_month.strftime("%Y%m")
    calc_sum(date, true)
  end

  def self.calc_sum(date = nil, monthly = false)
    s =  "start calc_sum #{Time.now} parameter date=#{date} monthly=#{monthly}"
    puts s ; logger.info s
    if monthly # monthly calculate data each month
      unless date.length == 6
        p "input YYYYMM" 
        return false
      end
      date_timestamp =  Time.zone.parse("#{date}01")
      calc_users(Time.new('1970-01-01'), date_timestamp.end_of_month, 1)
      calc_items(Time.new('1970-01-01'), date_timestamp.end_of_month, 1)
      calc_missing_items(Time.new('1970-01-01'), date_timestamp.end_of_month, 1)
      calc_consultations(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 1)      
      calc_inout_items(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 1)
      calc_library_use(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 1)
      calc_loans(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 1)
      calc_reminders(date_timestamp.beginning_of_month, date_timestamp.end_of_month, 1)
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
      calc_items(Time.new('1970-01-01'), date.end_of_day, 2)
      calc_missing_items(Time.new('1970-01-01'), date.end_of_day, 2)
      while i < 24 #  0 ~ 24 hour
        calc_checkouts(date.change(:hour => i), date.change(:hour => i + 1), 3)
        calc_checkins(date.change(:hour => i), date.change(:hour => i + 1), 3)
        calc_reserves(date.change(:hour => i), date.change(:hour => i + 1), 3)
        calc_questions(date.change(:hour => i), date.change(:hour => i + 1), 3)
        i += 1
      end
      calc_consultations(date.beginning_of_day, date.end_of_day, 2)
      calc_age_data(date.beginning_of_day, date.end_of_day, 2)
      calc_inout_items(date.beginning_of_day, date.end_of_day, 2)
      calc_loans(date.beginning_of_day, date.end_of_day, 2)
      calc_reminders(date.beginning_of_day, date.end_of_day, 2)
      calc_daily_data(date.strftime("%Y%m%d"))
    end
    rescue Exception => e
      p "Failed to start calculation: #{e}"
      logger.fatal "Failed to start calculation: #{e}"
      logger.fatal e.backtrace.join("\n")
  end

  def check_record
    record = Statistic.where(:data_type => self.data_type, :yyyymmdd => self.yyyymmdd, :yyyymm => self.yyyymm, :library_id => self.library_id, :hour => self.hour, :checkout_type_id => self.checkout_type_id, :shelf_id => self.shelf_id, :ndc => self.ndc, :call_number => self.call_number, :age => self.age, :option => self.option, :area_id => self.area_id, :user_type => self.user_type, :user_id => self.user_id).first
    record.destroy if record
  end
  
  def self.call_numbers
    call_numbers = []
    @libraries.each do |library|
      delimi = library.call_number_delimiter
      delimi = '|' if delimi.nil? || delimi.empty?
      # if you change the rule to scan, modify "# items each call_numbers" above too
      call_numbers << Item.joins(:shelf).where(["shelves.library_id = ?", library.id]).inject([]) {|nums, item| nums << item.call_number.split(delimi)[1] unless item.call_number.nil?; nums}.compact
    end
    return call_numbers.flatten.uniq!
  end

end
