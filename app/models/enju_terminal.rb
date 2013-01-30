class EnjuTerminal < ActiveRecord::Base
  attr_accessible :checkouts_autoprint, :comment, :ipaddr, :manifestation_autoprint, :name, :reserve_autoprint

  require 'resolv'

  validates :ipaddr,
	:uniqueness => true,
	:presence => true,
	:length => { :maximum => 15 },
        :format => { :with => Resolv::IPv4::Regex }
end
