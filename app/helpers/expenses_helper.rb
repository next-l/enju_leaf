module ExpensesHelper
  def to_format(num = 0)
    num.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')
  end
end
