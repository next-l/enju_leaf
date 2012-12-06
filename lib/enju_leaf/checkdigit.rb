# -*- encoding: utf-8 -*- 
module GenerateCheckdigit
  def generate_checkdigit_modulas10_weight3(num)
    # modulus 10/weight 3
    pos = total_even = total_odd = 0 
    (num.to_s + '0').reverse.split(//).each do |s|  
      pos += 1   
      # 偶数桁、奇数桁を判断し、それぞれ加算。  
      (pos % 2) == 0 ? total_even += s.to_i : total_odd += s.to_i  
    end  
    n = 10 - (total_even * 3 + total_odd * 1) % 10
    return n
  end 
end
