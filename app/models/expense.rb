class Expense < ActiveRecord::Base
  belongs_to :budget
  belongs_to :item

  validates_numericality_of :price, :allow_blank => true
  validates_presence_of :budget_id, :item_id
  attr_accessor :term_from, :term_to

  def item
    Item.find(self.item_id) rescue nil
  end
 
  def self.export_tsv(expenses)
    dir_base = "#{RAILS_ROOT}/private/system"
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
     
      expenses.each do |expense|
        columns.each do |column|
          case column[0]
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
            row << expense.price
          end
        end
        output.print "\""+row.join("\"\t\"")+"\"\n"
      end
    end
    return tsv_file
  end
  
  def self.export_pdf(expenses)
    logger.error "export pdf"
  end

end


