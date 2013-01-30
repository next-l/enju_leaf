module EnjuTerminalsHelper

  def is_checkouts_autoprint?(ipaddr)
    x = EnjuTerminal.find(:first, :conditions => [ "ipaddr = ?", ipaddr])
    unless x.nil?
      return x.checkouts_autoprint
    else
      return SystemConfiguration.find(:first,
	:conditions => [ "keyname = ?", "checkouts_print.auto_print"]
        ).v == true
    end
  end

  def is_reserve_autoprint?(ipaddr)
    x = EnjuTerminal.find(:first, :conditions => [ "ipaddr = ?", ipaddr])
    unless x.nil?
      return x.reserve_autoprint
    else
      return SystemConfiguration.find(:first,
	:conditions => [ "keyname = ?", "reserve_print.auto_print"]
        ).v == true
    end
  end

  def is_manifestation_autoprint?(ipaddr)
    x = EnjuTerminal.find(:first, :conditions => [ "ipaddr = ?", ipaddr])
    unless x.nil?
      return x.manifestation_autoprint
    else
      return SystemConfiguration.find(:first,
	:conditions => [ "keyname = ?", "manifestation_print.auto_print"]
        ).v == true
    end
  end

end
