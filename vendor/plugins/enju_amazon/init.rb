require 'enju_amazon'
ActiveRecord::Base.send :include, EnjuAmazon
ActionView::Base.send :include, EnjuAmazonHelper
