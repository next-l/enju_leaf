# -*- encoding: utf-8 -*- 
class EnjuTrunkNumberingError < StandardError ; end
class EnjuTrunkNumberingConflictError < StandardError ; end

class Numbering < ActiveRecord::Base
  attr_accessible :checkdigit, :display_name, :last_number, :name, :padding, :padding_number, :padding_character, :prefix, :suffix

  validates_presence_of :name, :display_name
  validates_numericality_of :last_number, :allow_blank => true
  validates_numericality_of :padding_number, :allow_blank => true
  validates_uniqueness_of :name
  before_save :set_padding_character 

  include GenerateCheckdigit
  class << self
    include GenerateCheckdigit
  end

  def set_padding_character
    self.padding_character = 0 unless padding_character
  end

  def padding?
    return padding
  end

  def self.do_numbering(name, is_save = true)
    counter = 10
    n = nil
    number = ''
    Numbering.transaction do
      begin
        #n = Numbering.find_by_name(name, :lock => 'FOR UPDATE NOWAIT')
        n = Numbering.find_by_name(name, :lock => true)
      rescue ActiveRecord::StatementInvalid => e
        # TODO : PG::Error: ERROR:  could not obtain lock on row in relation "numberings"
        puts $!
        if counter < 1
          raise EnjuTrunkNumberingError, "NumberingType lock error record. name=#{name}"
        end
        counter = counter - 1
        logger.info "lock record detected. sleep 0.3s remain count=#{counter}"
        sleep 0.3
        retry
      end
      unless n
        raise EnjuTrunkNumberingError, "NumberingType no record. name=#{name}"
      end

      number = n.last_number ? (n.last_number.to_i):(0)
      number = number + 1
      n.update_attribute :last_number, number.to_s
      #puts "number=#{number}"
      #pp number
    end

    prefix = (n.prefix.blank?)?(""):(n.prefix)
    suffix = (n.suffix.blank?)?(""):(n.suffix)

    if n.padding?
      padding_character = n.padding_character ? (n.padding_character.to_s):('')
      padding_digit = n.padding_number ? (n.padding_number):(0)
      if padding_digit == 0
        logger.warn "padding_digit invalid (nil or 0)"
      end
      if padding_character.blank?
        logger.warn "padding_charaacter invalid (blank)"
      end

      nstr = number.to_s.rjust(padding_digit, padding_character)
    else
      nstr = number.to_s
    end

    checkdigitstr = ""
    checkdigit = n.checkdigit ? (n.checkdigit):(0)
    #puts "checkdigit=#{checkdigit}"
    case checkdigit
    when 0
    when 1
      # modulus 10/weight 3
      checkdigitstr = generate_checkdigit_modulas10_weight3(number)
    end

    r = "#{prefix}#{nstr}#{suffix}#{checkdigitstr}"
    #puts "r=#{r}"
    return r
  end
  
end


