class Expense < ActiveRecord::Base
  belongs_to :budget
  belongs_to :item

  validates_numericality_of :price, :allow_blank => true
  validates_presence_of :item_id
  attr_accessor :term_from, :term_to

  def item
    Item.find(self.item_id) rescue nil
  end
 
  def self.export_tsv(expenses)
    dir_base = "#{Rails.root}/private/system"
    out_dir = "#{dir_base}/expense/"
    tsv_file = out_dir + "expenses.tsv"
    FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    # header
    columns = [
      ["budget",'activerecord.attributes.expense.budget'],
      [:library, 'activerecord.models.library'],
      ["created_at", 'activerecord.attributes.expense.created_at'],
      [:bookstore, 'activerecord.models.bookstore'],
      [:original_title, 'activerecord.attributes.manifestation.original_title'],
      [:item_identifier, 'activerecord.attributes.item.item_identifier'],
      ["price", 'activerecord.attributes.expense.price'] 
    ]
    File.open(tsv_file, "w") do |output|
      # add UTF-8 BOM for excel
      output.print "\xEF\xBB\xBF".force_encoding("UTF-8")

      # タイトル行
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      output.print "\""+row.join("\"\t\"")+"\"\n"
     
      expenses.each do |expense|
        row = []
        columns.each do |column|
          case column[0]
          when "budget"
            begin 
              budget = "#{expense.budget.library.display_name.localize} #{expense.budget.term.display_name.localize}"
              budget += "(#{expense.budget.note})" unless expense.budget.note.nil?
              row << budget
            rescue
              row << ""
            end
          when :library
            row << expense.item.shelf.library.display_name.localize rescue ""
          when "created_at"
            row << I18n.t('expense.date_format', :year => expense.created_at.strftime("%Y"), :month => expense.created_at.strftime("%m"), :date => expense.created_at.strftime("%d"))
          when :bookstore
            row << expense.item.bookstore.name rescue ""
          when :original_title
            row << expense.item.manifestation.original_title rescue ""
          when :item_identifier
            row << expense.item.item_identifier rescue ""
          when "price"
            row << to_format(expense.price)
          end
        end
        output.print "\""+row.join("\"\t\"")+"\"\n"
      end
    end
    return tsv_file
  end
  
  def self.export_pdf(expenses)
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/expenses/expense_list"
      report.events.on :page_create do |e|
        e.page.item(:page).value(e.page.no)
      end
      report.events.on :generate do |e|
        e.pages.each do |page|
          page.item(:total).value(e.report.page_count)
        end
      end

      report.start_new_page
      report.page.item(:date).value(Time.zone.now)
      sum = 0
      expenses.each do |expense|
        report.page.list(:list).add_row do |row|
          budget = "#{expense.budget.library.display_name.localize} #{expense.budget.term.display_name.localize}" rescue ""
          budget += "(#{expense.budget.note})" unless expense.budget.note.nil? rescue ""
          row.item(:budget).value(budget)        
          row.item(:library).value(expense.item.shelf.library.display_name.localize) rescue nil        
          row.item(:created_at).value(I18n.t('expense.date_format', :year => expense.created_at.strftime("%Y"), :month => expense.created_at.strftime("%m"), :date => expense.created_at.strftime("%d"))) rescue nil        
          row.item(:bookstore).value(expense.item.bookstore.name) rescue nil        
          row.item(:title).value(expense.item.manifestation.original_title) rescue nil        
          row.item(:item_identifier).value(expense.item.item_identifier) rescue nil        
          row.item(:price).value(to_format(expense.price))
          sum += expense.price        
        end
      end
      report.page.list(:list).add_row do |row|
        row.item(:price).value(to_format(sum))
      end
      return report.generate
    rescue Exception => e
      logger.error "Failed to create PDF file: #{e}"
    end
  end

private
  def self.to_format(num = 0)
    num.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end


