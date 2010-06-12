require 'enju_calil_library'
require 'enju_calil_check'
ActiveRecord::Base.send :include, EnjuCalilLibrary
ActiveRecord::Base.send :include, EnjuCalilCheck
